output "app_security_group_id" {
  description = "ID of the Application Security Group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the Database Security Group"
  value       = aws_security_group.db.id
}