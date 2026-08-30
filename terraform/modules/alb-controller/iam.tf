resource "aws_iam_policy" "this" {
  name = "${var.project}-${var.environment}-alb-controller"
  description = "IAM policy for the ALB Controller"

  policy = file("${path.module}/iam_policy.json")

  tags = local.common_tags
}