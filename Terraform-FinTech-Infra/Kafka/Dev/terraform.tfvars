# terraform.tfvars: the VALUES for the Dev Kafka stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "kafka"
environment  = "Dev"

############################ Networking lookup ############################
state_bucket         = "fintech-remote-backed-statefiles"
networking_state_key = "networking/env/dev/networking.tfstate"
vpc_name             = "FinTech-App-Dev"

############################ Kafka ############################
cluster_name = "fintech-kafka-dev"
