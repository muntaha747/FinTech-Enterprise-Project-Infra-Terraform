# variables.tf: the INPUTS this stack accepts. Values are set in terraform.tfvars.

variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "project_name" {
  description = "Project tag value on every resource"
  type        = string
}

variable "stack_name" {
  description = "Stack tag value on every resource"
  type        = string
}

variable "environment" {
  description = "Environment name: Prod, Stage, QA or Dev"
  type        = string
}

variable "organization" {
  description = "Organization name tagged on every resource"
  type        = string
}

variable "tgw_name" {
  description = "Name of the Transit Gateway"
  type        = string
}

# One entry per VPC: the key is the VPC name, the value is its settings.
# Security group rules are maps: rule name => settings. Leave a rule set out = no rules.
variable "vpc_setup" {
  description = "Settings for every VPC to create (VPC name => settings)"
  type = map(object({
    cidr                = string
    public_subnets      = optional(map(string), {}) # CIDR = AZ
    private_subnets     = map(string)               # CIDR = AZ
    enable_nat_gateway  = bool
    interface_endpoints = list(string)

    public_ingress = optional(map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })), {})

    public_egress = optional(map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })), {})

    private_ingress = optional(map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })), {})

    private_egress = optional(map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })), {})
  }))
}
