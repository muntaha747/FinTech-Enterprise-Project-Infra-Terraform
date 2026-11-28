# vpc.tf: builds the VPC.
# This module makes ONE VPC. The root calls it once for each VPC.

locals {
  # Tags put on every resource
  common_tags = merge(var.tags, {
    Environment  = var.environment
    Organization = var.organization
  })

  # true / false switches used in the other files
  has_public_subnets  = length(var.public_subnets) > 0
  has_private_subnets = length(var.private_subnets) > 0
  create_nat          = var.enable_nat_gateway && local.has_public_subnets
}

############################ VPC ############################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = var.vpc_name })
}

############################ Default security group ############################
# AWS makes a default security group that allows traffic. We take it over and give it no rules.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-default-sg-locked" })
}
