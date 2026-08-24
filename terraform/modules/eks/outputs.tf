output "cluster_role_arn" {
  description = "Amazon EKS cluster IAM Role ARN"
  value = aws_iam_role.eks_cluster.arn
}

output "cluster_name" {
  description = "Amazon EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_version" {
  description = "Amazon EKS Kubernetes version"
  value       = aws_eks_cluster.this.version
}

output "cluster_arn" {
  description = "Amazon EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Amazon EKS Kubernetes API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "node_group_role_arn" {
  value = aws_iam_role.eks_node_group.arn
}

output "node_group_name" {
  description = "Amazon EKS managed node group name"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_role_arn" {
  description = "IAM role ARN used by EKS worker nodes"
  value       = aws_iam_role.eks_node_group.arn
}