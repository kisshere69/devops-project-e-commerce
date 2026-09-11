data "aws_iam_policy_document" "db_migration_secrets" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      aws_secretsmanager_secret.rds_credentials.arn
    ]
  }
}

resource "aws_iam_policy" "db_migration_secrets" {
  name   = "${var.project}-${var.environment}-db-migration-secrets"
  policy = data.aws_iam_policy_document.db_migration_secrets.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "db_migration_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "app_secrets" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      aws_secretsmanager_secret.rds_credentials.arn
    ]
  }
}

resource "aws_iam_policy" "app_secrets" {
  name   = "${var.project}-${var.environment}-app-secrets"
  policy = data.aws_iam_policy_document.app_secrets.json

  tags = local.common_tags
}

resource "aws_iam_role" "db_migration" {
  name               = "${var.project}-${var.environment}-db-migration"
  assume_role_policy = data.aws_iam_policy_document.db_migration_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "db_migration_secrets" {
  role       = aws_iam_role.db_migration.name
  policy_arn = aws_iam_policy.db_migration_secrets.arn
}


resource "aws_iam_role" "app" {
  name               = "${var.project}-${var.environment}-app"
  assume_role_policy = data.aws_iam_policy_document.db_migration_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "app_secrets" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_secrets.arn
}