terraform {
  backend "s3" {
    bucket       = "fintech-project-statefile-bucket"
    key          = "rds/env/prod/rds.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}