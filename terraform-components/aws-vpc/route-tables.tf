### Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  # Note that the default route, mapping the VPC's CIDR block to "local", 
  # is created implicitly and cannot be specified.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-rtb-public"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

### Private route tables
resource "aws_route_table" "private" {
  count  = length(local.flat_private_subnets)
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name                   = "${var.vpc_name}-rtb-private-${local.flat_private_subnets[count.index].availability_zone}-${local.flat_private_subnets[count.index].tier_name}"
      Tier                   = local.flat_private_subnets[count.index].tier_name
      AvailabilityZone       = local.flat_private_subnets[count.index].availability_zone
      PublicFacing           = local.flat_private_subnets[count.index].public_facing
      S3VpcEndpointConnected = local.flat_private_subnets[count.index].connect_s3_vpc_endpoint
    },
    var.tags
  )
}

# Note that the default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.
resource "aws_route" "nat_gateway" {
  count                  = var.enable_nat_gateway ? length(local.route_tables_public_facing) : 0
  route_table_id         = local.route_tables_public_facing[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.enable_multiaz_nat_gateway ? [for ng in aws_nat_gateway.main :
  ng.id if ng.tags["AvailabilityZone"] == local.route_tables_public_facing[count.index].tags["AvailabilityZone"]][0] : aws_nat_gateway.main[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_route_table.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

### S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = merge(
    {
      Name = "${var.vpc_name}-vpce-s3"
    },
    var.tags
  )
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  count           = var.enable_s3_endpoint ? length(local.route_tables_s3_vpc_endpoint_associated) : 0
  route_table_id  = local.route_tables_s3_vpc_endpoint_associated[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}
