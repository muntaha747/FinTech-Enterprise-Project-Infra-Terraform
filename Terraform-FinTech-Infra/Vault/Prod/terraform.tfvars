# terraform.tfvars: the VALUES for the Prod Vault stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "vault"
environment  = "Prod"

############################ Networking lookup ############################
state_bucket         = "fintech-remote-backed-statefiles"
networking_state_key = "networking/env/prod/networking.tfstate"
ops_vpc_name         = "FinTech-Ops"

############################ Vault server ############################
vault_name          = "FinTech-Vault"
instance_type       = "t3.medium"
allowed_cidr_blocks = ["10.0.0.0/8"] # all FinTech VPCs (EKS reaches Vault through the Transit Gateway)
