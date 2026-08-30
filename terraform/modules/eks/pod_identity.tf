resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"

  tags = local.common_tags
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name

  namespace       = "kube-system"
  service_account = "aws-node"

  role_arn = aws_iam_role.vpc_cni.arn
}