# terraform.tfvars: the VALUES for the Prod Kafka stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "kafka"
environment  = "Prod"

############################ Networking lookup ############################
state_bucket         = "fintech-remote-backed-statefiles"
networking_state_key = "networking/env/prod/networking.tfstate"
vpc_name             = "FinTech-App"

############################ Kafka ############################
cluster_name = "fintech-kafka-prod"
