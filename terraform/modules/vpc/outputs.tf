output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "app_server_sg_id" {
  description = "App server security group ID"
  value       = aws_security_group.app_server.id
}

output "rds_sg_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
  description = "ID of the NAT gateway"
}


