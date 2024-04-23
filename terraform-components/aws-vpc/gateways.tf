### Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-igw"
    },
    var.tags
  )
}

### NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.enable_multiaz_nat_gateway ? length(var.public_subnet_cidr_blocks) : 1) : 0
  domain = "vpc"

  tags = merge(
    {
      Name             = "${var.vpc_name}-eip-nat-public${count.index + 1}"
      AvailabilityZone = data.aws_availability_zones.available.names[count.index]
    },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.enable_multiaz_nat_gateway ? length(var.public_subnet_cidr_blocks) : 1) : 0
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]

  subnet_id         = aws_subnet.public[var.enable_multiaz_nat_gateway ? count.index : 0].id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat[count.index].id


  tags = merge(
    {
      Name             = "${var.vpc_name}-nat-public${count.index + 1}"
      AvailabilityZone = data.aws_availability_zones.available.names[count.index]
    },
    var.tags
  )
}
