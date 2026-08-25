# Default tags

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment"
  type        = string
}

variable "managed_by" {
  description = "Tool responsible for managing the infrastructure"
  type        = string
  default     = "Terraform"
}

# VPC

variable "vpc_cidr" {
  description = "A VPC used for the project"
  type = string
}