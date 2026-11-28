# providers.tf: which cloud to talk to, and in which region.
# Pick the AWS account with:  export AWS_PROFILE=root-user  (the pipeline uses its own login)
provider "aws" {
  region = var.region
}
