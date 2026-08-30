output "repository" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "Amazon ECR repository ARN"
  value       = aws_ecr_repository.this.arn
}