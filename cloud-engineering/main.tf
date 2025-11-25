# Setup and Set Provider as AWS
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Constants and variables
locals {
  vpc_cidr = "10.0.0.0/16" // IP range for whole network
  azs = ["us-east-1a", "us-east-1b"] // Two Availability Zones
  common_tags = {
    Project = "Secure-Multi-Tier-VPC"
    Owner = "admin"
  }
}

# Create virtual network
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(local.common_tags, {Name = "production-vpc"})
}

# Router to connect VPC to internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {Name = "production-igw"})
}

# Create Public Subnet
resource "aws_subnet" "public" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, count.index) // Adds 8 bits to netmask(10.0.0.0/24, 10.0.1.0/24)
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true // Public IP
  tags = merge(local.common_tags, {Name = "public-subnet-${count.index + 1}"})
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, count.index + 2) # 10.0.2.0/24, 10.0.3.0/24
  availability_zone = local.azs[count.index]
  tags = merge(local.common_tags, {Name = "private-subnet-${count.index + 1}"})
}

# Private Data Subnets
resource "aws_subnet" "private_data" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, count.index + 4) # 10.0.4.0/24, 10.0.5.0/24
  availability_zone = local.azs[count.index]
  tags = merge(local.common_tags, {Name = "private-data-subnet-${count.index + 1}"})
}

# Allocate Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count = length(local.azs)
  domain = "vpc"
  tags = merge(local.common_tags, {Name = "elastic-ip-${count.index + 1}"})
}

# Create NAT Gateway in Public Subnets
resource "aws_nat_gateway" "nat" { // Static IP address
  count = length(local.azs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public[count.index].id
  tags = merge(local.common_tags, {Name = "nat-gw-${count.index + 1}"})
  depends_on = [aws_internet_gateway.igw] // Safety instruction that only builds NAT Gateway after Internet is done
}

# Public Route Table (IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, {Name = "public-route"})
}

resource "aws_route_table_association" "public" {
  count = length(local.azs)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Route Table (NAT GW)
resource "aws_route_table" "private_app" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(local.common_tags, {Name = "private-app-route-${count.index + 1}"})
}

resource "aws_route_table_association" "private_app" {
  count = length(local.azs)
  subnet_id = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Private Data Route Table (Isolated)
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id
  # No route to 0.0.0.0/0
  tags = merge(local.common_tags, {Name = "private-data-route"})
}

resource "aws_route_table_association" "private_data" {
  count = length(local.azs)
  subnet_id = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data.id
}

# Bastion SG: Allows SSH from Internet
resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["96.250.8.229/32"] # Restricts to my IP so add in your own for it work
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {Name = "bastion-sg"})
}

# Load Balancer SG
resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  description = "Security group for Public Load Balancer"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App Tier SG: Accepts traffic ONLY from ALB and Bastion
resource "aws_security_group" "app_sg" {
  name = "app-sg"
  description = "Security group for App Tier"
  vpc_id = aws_vpc.main.id

  # Allow HTTP/HTTPS from ALB
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  # Allow SSH from Bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data Tier SG: Accepts traffic ONLY from App Tier
resource "aws_security_group" "data_sg" {
  name = "data-sg"
  description = "Security group for Data Tier"
  vpc_id = aws_vpc.main.id

  # Allow Database traffic from App SG
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  tags = merge(local.common_tags, {Name = "data-sg"})
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  # Allow Internet
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 443
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "96.250.8.229/32"
    from_port = 22
    to_port = 22
  }

  # Return traffic
  ingress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  # Allow all outbound
  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags = merge(local.common_tags, {Name = "public-nacl"})
}