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

# EKS Cluster

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Amazon EKS cluster version"
  type        = string
}

# VPC

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}