# locals.tf: values WORKED OUT from the variables.

locals {
  # Tags added to every bucket
  common_tags = {
    Project = var.project_name
    Stack   = var.stack_name
  }
}
