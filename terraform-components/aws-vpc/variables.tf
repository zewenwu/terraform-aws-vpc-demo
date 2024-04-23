### VPC network
variable "vpc_name" {
  description = "The name of the vpc"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "tier_info" {
  description = <<EOH
The info blocks for the private subnet structure for the tiers to deploy. 
Each block respresents a tier should have tier_name, cidr_blocks, availability_zones, public_facing, 
connect_s3_vpc_endpoint.
EOH
  type = list(object({
    tier_name               = string
    cidr_blocks             = list(string)
    availability_zones      = list(string)
    public_facing           = bool
    connect_s3_vpc_endpoint = bool

  }))
  default = [
    {
      tier_name               = "application"
      cidr_blocks             = ["10.0.128.0/20", "10.0.144.0/20"]
      availability_zones      = ["us-east-1a", "us-east-1b"]
      public_facing           = true
      connect_s3_vpc_endpoint = true
    },
    {
      tier_name               = "database"
      cidr_blocks             = ["10.0.160.0/20", "10.0.172.0/20"]
      availability_zones      = ["us-east-1a", "us-east-1b"]
      public_facing           = false
      connect_s3_vpc_endpoint = false
    }
  ]
}

### S3 VPC Endpoint
variable "enable_s3_endpoint" {
  description = "Enable S3 VPC endpoint"
  type        = bool
  default     = true
}

### NAT Gateways
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = false
}

variable "enable_multiaz_nat_gateway" {
  description = "Enable Multi-AZ NAT Gateway"
  type        = bool
  default     = false
}

### Metadata
variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys."
  type        = map(any)
  default     = {}
}
