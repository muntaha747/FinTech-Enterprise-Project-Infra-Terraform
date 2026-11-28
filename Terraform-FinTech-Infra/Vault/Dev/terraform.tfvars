# terraform.tfvars: the VALUES for the Dev Vault stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "vault"
environment  = "Dev"

############################ Networking lookup ############################
state_bucket         = "fintech-remote-backed-statefiles"
networking_state_key = "networking/env/dev/networking.tfstate"
ops_vpc_name         = "FinTech-Ops-Dev"

############################ Vault server ############################
vault_name          = "FinTech-Vault-Dev"
instance_type       = "t3.medium"
allowed_cidr_blocks = ["10.0.0.0/8"] # all FinTech VPCs (EKS reaches Vault through the Transit Gateway)
