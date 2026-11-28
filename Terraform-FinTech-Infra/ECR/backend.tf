# backend.tf: where the state file is stored
terraform {
  backend "s3" {
    bucket       = "fintech-remote-backed-statefiles"
    key          = "ecr/envs/ecr.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
