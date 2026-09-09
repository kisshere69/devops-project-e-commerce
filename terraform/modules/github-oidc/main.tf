data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        var.github_oidc_subject
      ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = local.common_tags
}

# ECR permissions required by GitHub Actions
data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid    = "GetECRAuthorizationToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushImageToECR"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = [
      "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${var.repository}",
      "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${var.db_migration_repository}"
    ]
  }
}

# Permission required by "aws eks update-kubeconfig"
data "aws_iam_policy_document" "eks_access" {
  statement {
    sid    = "DescribeEKSCluster"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      var.cluster_arn
    ]
  }
}

# IAM Role assumed by GitHub Actions through OIDC
resource "aws_iam_role" "github_actions" {
  name               = "${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_policy" "ecr_push" {
  name        = "${var.project}-${var.environment}-github-actions-ecr-push"
  description = "Allow GitHub Actions to push Docker images to ECR"

  policy = data.aws_iam_policy_document.ecr_push.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_push.arn
}

resource "aws_iam_policy" "eks_access" {
  name        = "${var.project}-${var.environment}-github-actions-eks-access"
  description = "Allow GitHub Actions to describe the EKS cluster"

  policy = data.aws_iam_policy_document.eks_access.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.eks_access.arn
}

# Allow the GitHub Actions IAM role to authenticate to EKS
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"

  kubernetes_groups = [
    "github-actions-deployers"
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-github-actions-access"
    }
  )
}