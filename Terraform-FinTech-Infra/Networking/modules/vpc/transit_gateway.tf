# transit_gateway.tf: connects this VPC to the other VPCs through the Transit Gateway.

# Plug the VPC into the Transit Gateway (one private subnet per AZ)
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach" {
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = local.one_private_subnet_per_az
  tags               = merge(local.common_tags, { Name = "${var.vpc_name}-tgw-attach" })
}

# Traffic for the other VPCs (10.0.0.0/8) goes to the Transit Gateway
resource "aws_route" "to_tgw" {
  route_table_id         = aws_route_table.private_route_table[0].id
  destination_cidr_block = var.tgw_destination_cidr_block
  transit_gateway_id     = var.tgw_id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.tgw_attach]
}
