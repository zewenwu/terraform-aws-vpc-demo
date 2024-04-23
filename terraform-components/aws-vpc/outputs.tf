
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the deployed VPC"
}

output "public_subnets_ids" {
  value       = aws_subnet.public[*].id
  description = "The IDs of the deployed public subnets"
}

output "private_subnets_ids" {
  value       = { for subnet in aws_subnet.private : subnet.tags.Tier => subnet.id... }
  description = "The IDs of the deployed private subnets, identified by the tier name."
}
