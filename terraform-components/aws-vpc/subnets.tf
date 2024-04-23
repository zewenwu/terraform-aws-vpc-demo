resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.vpc_name}-vpc"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name             = "${var.vpc_name}-subnet-public-${data.aws_availability_zones.available.names[count.index]}"
      AvailabilityZone = data.aws_availability_zones.available.names[count.index]
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count             = length(local.flat_private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.flat_private_subnets[count.index].cidr_block
  availability_zone = local.flat_private_subnets[count.index].availability_zone

  tags = merge(
    {
      Name                   = "${var.vpc_name}-subnet-private-${local.flat_private_subnets[count.index].availability_zone}-${local.flat_private_subnets[count.index].tier_name}"
      Tier                   = local.flat_private_subnets[count.index].tier_name
      AvailabilityZone       = local.flat_private_subnets[count.index].availability_zone
      PublicFacing           = local.flat_private_subnets[count.index].public_facing
      S3VpcEndpointConnected = local.flat_private_subnets[count.index].connect_s3_vpc_endpoint
    },
    var.tags
  )
}
