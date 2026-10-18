output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "ec2_private_ip" {
  description = "Private IP of the App Instance"
  value       = module.ec2.private_ip
}

output "rds_endpoint" {
  description = "Connection Endpoint for RDS PostgreSQL"
  value       = module.rds.db_endpoint
}