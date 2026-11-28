# backend.tf: where the state file is stored
terraform {
  backend "s3" {
    bucket       = "fintech-remote-backed-statefiles"
    key          = "platform-addons/env/dev/platform-addons.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
