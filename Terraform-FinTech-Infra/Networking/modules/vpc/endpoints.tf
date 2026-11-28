# endpoints.tf: reach AWS services (S3, ECR, KMS ...) privately, without the internet.

# Current region, so service names are not hard-coded
data "aws_region" "current" {}

############################ S3 endpoint (free) ############################
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private_route_table[*].id
  tags              = merge(local.common_tags, { Name = "${var.vpc_name}-s3-endpoint" })
}

############################ Endpoint security group ############################
# Allows HTTPS (443) from inside this VPC only
resource "aws_security_group" "endpoint_sg" {
  name        = "${var.vpc_name}-endpoint-sg"
  description = "HTTPS from inside ${var.vpc_name} to its VPC endpoints"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(local.common_tags, { Name = "${var.vpc_name}-endpoint-sg" })

  ingress {
    description = "HTTPS from this VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

############################ Interface endpoints ############################
# One endpoint per name in interface_endpoints, e.g. ["ecr.api", "kms"].
# for_each: removing one service later does not touch the others.
resource "aws_vpc_endpoint" "interfaces" {
  for_each            = toset(var.interface_endpoints)
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.one_private_subnet_per_az
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  tags                = merge(local.common_tags, { Name = "${var.vpc_name}-${each.key}-endpoint" })
}
