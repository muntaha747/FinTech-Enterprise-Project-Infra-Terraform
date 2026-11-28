terraform {
  backend "s3" {
    bucket       = "fintech-remote-backed-statefiles"
    key          = "rds/env/stage/rds.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}