module "vpc" {
  source = "../terraform-components/aws-vpc"

  vpc_name                  = "testvpc"
  vpc_cidr_block            = "10.1.0.0/16"
  public_subnet_cidr_blocks = ["10.1.0.0/20", "10.1.16.0/20"]
  tier_info = [
    {
      tier_name               = "application"
      cidr_blocks             = ["10.1.128.0/20", "10.1.144.0/20"]
      availability_zones      = ["us-east-1a", "us-east-1b"]
      public_facing           = true
      connect_s3_vpc_endpoint = true
    },
    {
      tier_name               = "database"
      cidr_blocks             = ["10.1.160.0/20", "10.1.176.0/20"]
      availability_zones      = ["us-east-1a", "us-east-1b"]
      public_facing           = false
      connect_s3_vpc_endpoint = false
    }
  ]

  enable_s3_endpoint = false

  enable_nat_gateway         = true
  enable_multiaz_nat_gateway = false

  tags = local.tags
}
