# backend.tf: where the state file is stored
terraform {
  backend "s3" {
    bucket       = "fintech-project-statefile-bucket"
    key          = "networking/env/stage/networking.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
