# main.tf: one private ECR repository per name.
# for_each: removing one repository name later does not touch the others.

resource "aws_ecr_repository" "repo" {
  for_each             = toset(var.repository_names)
  name                 = each.key
  image_tag_mutability = var.image_mutability # IMMUTABLE: a tag can never be overwritten
  tags                 = var.tags

  # Encrypt images with KMS
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  # Scan every pushed image for known vulnerabilities
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
