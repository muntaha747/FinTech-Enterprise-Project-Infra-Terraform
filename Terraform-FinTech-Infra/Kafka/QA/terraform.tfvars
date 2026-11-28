# terraform.tfvars: the VALUES for the QA Kafka stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "kafka"
environment  = "QA"

############################ Networking lookup ############################
state_bucket         = "fintech-remote-backed-statefiles"
networking_state_key = "networking/env/qa/networking.tfstate"
vpc_name             = "FinTech-App-QA"

############################ Kafka ############################
cluster_name = "fintech-kafka-qa"
