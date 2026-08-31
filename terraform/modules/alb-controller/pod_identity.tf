resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "alb-controller"
  role_arn        = aws_iam_role.this.arn
}