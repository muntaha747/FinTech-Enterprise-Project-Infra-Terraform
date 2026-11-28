# nat.tf: lets private subnets reach the internet (outbound only).
# Only made when enable_nat_gateway = true and the VPC has a public subnet.

# Fixed public IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  count      = local.create_nat ? 1 : 0
  domain     = "vpc"
  tags       = merge(local.common_tags, { Name = "${var.vpc_name}-nat-eip" })
  depends_on = [aws_internet_gateway.my_igw]
}

# NAT Gateway, placed in the first public subnet
resource "aws_nat_gateway" "nat_gateway" {
  count         = local.create_nat ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = values(aws_subnet.public_subnet)[0].id
  tags          = merge(local.common_tags, { Name = "${var.vpc_name}-nat" })
  depends_on    = [aws_internet_gateway.my_igw]
}

# Private subnets send internet traffic to the NAT Gateway
resource "aws_route" "nat_gateway_route_table" {
  count                  = local.create_nat && local.has_private_subnets ? 1 : 0
  route_table_id         = aws_route_table.private_route_table[0].id
  destination_cidr_block = var.internet_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
}
