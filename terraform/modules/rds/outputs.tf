output "endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.this.address
}