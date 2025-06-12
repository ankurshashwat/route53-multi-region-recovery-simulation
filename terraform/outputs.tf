# RDS
output "endpoint" {
  value       = module.rds.endpoint
  description = "Endpoint of the primary RDS instance"
}

output "secondary_endpoint" {
  value       = module.rds.secondary_endpoint
  description = "Endpoint of the secondary RDS instance"
}

output "db_instance_id" {
  value       = module.rds.db_instance_id
  description = "ID of the primary RDS instance"
}

output "secondary_db_instance_id" {
  value       = module.rds.secondary_db_instance_id
  description = "ID of the secondary RDS instance"
}

# Route53
output "primary_record_fqdn" {
  value       = module.route53.primary_record_fqdn
  description = "FQDN of the primary Route 53 record"
}

# EC2
output "instance_id" {
  value       = module.ec2.instance_id
  description = "Instance ID of the primary EC2 instance"
}

output "public_ip" {
  value       = module.ec2.public_ip
  description = "Public IP of the primary EC2 instance"
}

output "key_pair_name" {
  value       = module.ec2.key_pair_name
  description = "Name of the EC2 key pair"
}

# VPC
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "app_server_sg_id" {
  value       = module.vpc.app_server_sg_id
  description = "ID of the application server security group"
}

output "rds_sg_id" {
  value       = module.vpc.rds_sg_id
  description = "ID of the RDS security group"
}

output "nat_gateway_id" {
  value       = module.vpc.nat_gateway_id
  description = "ID of the NAT gateway"
}