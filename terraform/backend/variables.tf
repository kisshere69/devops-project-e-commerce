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

variable "purpose" {
  description = "Purpose of the infrastructure"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

# S3 bucket

variable "state_bucket_name" {
  description = "S3 bucket for the Terraform state"
  type        = string
}