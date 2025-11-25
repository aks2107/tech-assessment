# Setup and Set Provider as AWS
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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
  azs      = ["us-east-1a", "us-east-1b"] // Two Availability Zones
  
  common_tags = {
    Project = "Secure-Multi-Tier-VPC"
    Owner   = "CloudEngineer"
  }
}

# Create virtual network
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags, { Name = "production-vpc" })
}

# Router to connect VPC to internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create Public Subnet
resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index) // Adds 8 bits to netmask(10.0.0.0/24, 10.0.1.0/24)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true // Public IP
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, count.index + 2) # 10.0.2.0/24, 10.0.3.0/24
  availability_zone = local.azs[count.index]
}

# Private Data Subnets
resource "aws_subnet" "private_data" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, count.index + 4) # 10.0.4.0/24, 10.0.5.0/24
  availability_zone = local.azs[count.index]
}


