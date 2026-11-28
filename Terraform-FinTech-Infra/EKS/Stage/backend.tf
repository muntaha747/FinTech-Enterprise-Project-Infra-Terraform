# backend.tf: where the state file is stored
terraform {
  backend "s3" {
    bucket       = "fintech-remote-backed-statefiles"
    key          = "eks/env/stage/eks.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
