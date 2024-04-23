output "public_subnets_ids" {
  value = module.vpc.public_subnets_ids
}

output "private_subnets_ids" {
  value = module.vpc.private_subnets_ids
}
