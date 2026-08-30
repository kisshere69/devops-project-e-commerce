# EKS Cluster

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  version = var.cluster_version

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = local.common_tags
}

# EKS Managed Node Group

resource "aws_eks_node_group" "this" {
  node_group_name = var.eks_node_group_name
  cluster_name    = var.cluster_name
  node_role_arn   = aws_iam_role.eks_node_group.arn

  subnet_ids = var.private_subnet_ids

  version = var.cluster_version

  instance_types = var.node_instance_types
  capacity_type  = var.node_capacity_type
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    environment = var.environment
    node-group  = var.eks_node_group_name
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.eks_node_group_name}"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_ecr_pull_policy,
    aws_iam_role_policy_attachment.vpc_cni,
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.vpc_cni
  ]
}