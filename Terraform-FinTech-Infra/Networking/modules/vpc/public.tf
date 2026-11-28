# public.tf: public subnets and their way to the internet.
# Nothing here is made if the VPC has no public subnets.

############################ Internet Gateway ############################
resource "aws_internet_gateway" "my_igw" {
  count  = local.has_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-igw" })
}

############################ Public subnets ############################
# One subnet per line in public_subnets (CIDR = AZ).
# for_each (not count): removing one subnet later does not touch the others.
resource "aws_subnet" "public_subnet" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags              = merge(local.common_tags, { Name = "${var.vpc_name}-public-${each.value}-${each.key}" })
}

############################ Public route table ############################
resource "aws_route_table" "public_route_table" {
  count  = local.has_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-public-rt" })
}

# Internet traffic goes to the Internet Gateway
resource "aws_route" "public_route" {
  count                  = local.has_public_subnets ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[0].id
  destination_cidr_block = var.internet_cidr_block
  gateway_id             = aws_internet_gateway.my_igw[0].id
}

# Connect each public subnet to the public route table
resource "aws_route_table_association" "public_route_table_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table[0].id
}

############################ Public security group ############################
# Each line in public_ingress / public_egress (terraform.tfvars) becomes one rule.
resource "aws_security_group" "public_subnet_sg" {
  # checkov:skip=CKV2_AWS_5: Other stacks attach this group
  count       = local.has_public_subnets ? 1 : 0
  name        = "${var.vpc_name}-public-sg"
  description = "Public security group of ${var.vpc_name}"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(local.common_tags, { Name = "${var.vpc_name}-public-sg" })

  dynamic "ingress" {
    for_each = var.public_ingress
    content {
      description = "Inbound: ${ingress.key}"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.public_egress
    content {
      description = "Outbound: ${egress.key}"
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
