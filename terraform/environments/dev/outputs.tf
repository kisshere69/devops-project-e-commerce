output "aws_account_id" {
  description = "AWS Account ID"

  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  description = "Current IAM ARN"

  value = data.aws_caller_identity.current.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Amazon EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Amazon EKS Kubernetes API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Amazon EKS managed node group name"
  value       = module.eks.node_group_name
}