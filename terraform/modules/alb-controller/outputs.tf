output "iam_role_arn" {
  description = "IAM role ARN used by ALB Controller"
  value       = aws_iam_role.this.arn
}

output "iam_policy_arn" {
  description = "IAM policy ARN for ALB Controller"
  value       = aws_iam_policy.this.arn
}

output "pod_identity_association_id" {
  description = "EKS Pod Identity association ID for ALB Controller"
  value       = aws_eks_pod_identity_association.this.id
}