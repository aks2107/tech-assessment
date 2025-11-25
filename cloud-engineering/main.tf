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
