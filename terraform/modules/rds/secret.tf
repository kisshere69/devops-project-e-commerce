resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${var.project}-${var.environment}-rds-credentials"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    DATABASE_URL = "postgresql+psycopg://${var.db_username}:${random_password.rds_master.result}@${aws_db_instance.this.address}:5432/${var.db_name}"
  })
}