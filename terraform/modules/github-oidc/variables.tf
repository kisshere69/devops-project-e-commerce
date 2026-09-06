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

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

# EKS Cluster

variable "cluster_name" {
  description = "EKS cluster name to grant access entry for"
  type        = string
}

variable "cluster_arn" {
  description = "EKS cluster ARN, needed for access entry resource"
  type        = string
}

# GitHub OIDC

variable "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  type        = string
}

variable "github_oidc_subject" {
  description = "Subject of the GitHub OIDC provider"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo in org/repo format"
  type        = string
}

# ECR

variable "repository" {
  description = "The name of the ECR repository"
  type        = string
}