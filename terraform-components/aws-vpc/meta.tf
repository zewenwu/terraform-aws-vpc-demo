
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

locals {
  flat_private_subnets = flatten([
    for tier in var.tier_info :
    [for i in range(length(tier.cidr_blocks)) :
      {
        tier_name               = tier.tier_name,
        public_facing           = tier.public_facing,
        connect_s3_vpc_endpoint = tier.connect_s3_vpc_endpoint,
        cidr_block              = tier.cidr_blocks[i],
        availability_zone       = tier.availability_zones[i]
      }
    ]
  ])

  route_tables_public_facing = [
    for rt in aws_route_table.private :
    rt if rt.tags["PublicFacing"]
  ]

  route_tables_s3_vpc_endpoint_associated = [
    for rt in aws_route_table.private :
    rt if rt.tags["S3VpcEndpointConnected"]
  ]
}
