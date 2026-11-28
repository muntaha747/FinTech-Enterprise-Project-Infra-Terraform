# private.tf: private subnets. They have no direct internet access.

############################ Private subnets ############################
# One subnet per line in private_subnets (CIDR = AZ).
# for_each (not count): removing one subnet later does not touch the others.
resource "aws_subnet" "private_subnet" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags              = merge(local.common_tags, { Name = "${var.vpc_name}-private-${each.value}-${each.key}" })
}

# The first private subnet in each AZ. Endpoints and the Transit Gateway need exactly one per AZ.
locals {
  private_subnets_by_az     = { for subnet in aws_subnet.private_subnet : subnet.availability_zone => subnet.id... }
  one_private_subnet_per_az = [for az, ids in local.private_subnets_by_az : ids[0]]
}

############################ Private route table ############################
resource "aws_route_table" "private_route_table" {
  count  = local.has_private_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-private-rt" })
}

# Connect each private subnet to the private route table
resource "aws_route_table_association" "private_route_table_association" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[0].id
}

############################ Private security group ############################
# Each line in private_ingress / private_egress (terraform.tfvars) becomes one rule.
resource "aws_security_group" "private_subnet_sg" {
  # checkov:skip=CKV2_AWS_5: Other stacks attach this group
  count       = local.has_private_subnets ? 1 : 0
  name        = "${var.vpc_name}-private-sg"
  description = "Private security group of ${var.vpc_name}"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(local.common_tags, { Name = "${var.vpc_name}-private-sg" })

  dynamic "ingress" {
    for_each = var.private_ingress
    content {
      description = "Inbound: ${ingress.key}"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.private_egress
    content {
      description = "Outbound: ${egress.key}"
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
