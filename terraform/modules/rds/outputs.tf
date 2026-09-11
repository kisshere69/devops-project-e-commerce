output "endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.this.address
}

output "secret_arn" {
  value = aws_secretsmanager_secret.rds_credentials.arn
}

output "db_migration_role_arn" {
  description = "IAM role ARN used by the database migration workload"
  value       = aws_iam_role.db_migration.arn
}

output "app_role_arn" {
  description = "IAM role ARN used by the application workload"
  value       = aws_iam_role.app.arn
}