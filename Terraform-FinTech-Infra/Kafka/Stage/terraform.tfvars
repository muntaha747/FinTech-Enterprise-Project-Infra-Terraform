# terraform.tfvars: the VALUES for the Stage Kafka stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "kafka"
environment  = "Stage"

############################ Networking lookup ############################
state_bucket         = "fintech-remote-backed-statefiles"
networking_state_key = "networking/env/stage/networking.tfstate"
vpc_name             = "FinTech-App-Stage"

############################ Kafka ############################
cluster_name = "fintech-kafka-stage"
