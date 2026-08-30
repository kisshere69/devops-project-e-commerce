resource "aws_iam_policy" "this" {
  name        = "${var.project}-${var.environment}-alb-controller"
  description = "IAM policy for the ALB Controller"

  policy = file("${path.module}/iam_policy.json")

  tags = local.common_tags
}

resource "aws_iam_role" "this" {
  name = "${var.project}-${var.environment}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}