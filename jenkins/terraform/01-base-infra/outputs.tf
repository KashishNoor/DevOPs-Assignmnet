output "vpc_id" {
  description = "Assignment 3 base VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_name" {
  description = "Assignment 3 base VPC Name tag"
  value       = "${var.project_name}-vpc"
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_names" {
  description = "Public subnet Name tags"
  value       = aws_subnet.public[*].tags.Name
}

output "private_subnet_names" {
  description = "Private subnet Name tags"
  value       = aws_subnet.private[*].tags.Name
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private.id
}