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

# EKS Managed Node Group

variable "eks_node_group_name" {
  description = "Amazon EKS node group name"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types"
  type        = list(string)
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS managed node group"
  type        = string

  validation {
    condition = contains(
      ["ON_DEMAND", "SPOT"],
      var.node_capacity_type
    )

    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number

  validation {
    condition     = var.node_desired_size >= 1
    error_message = "node_desired_size must be at least 1."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number

  validation {
    condition     = var.node_min_size >= 0
    error_message = "node_min_size cannot be negative."
  }
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number

  validation {
    condition     = var.node_max_size >= 1
    error_message = "node_max_size must be at least 1."
  }
}

variable "node_disk_size" {
  description = "Worker node root volume size in GiB"
  type        = number

  default = 20

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "node_disk_size must be at least 20 GB."
  }
}

# EKS Access Entry

variable "cluster_admin_principal_arn" {
  description = "IAM principal ARN granted administrative access to the EKS cluster"
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

variable "public_subnet_a_cidr" {
  description = "value"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "value"
  type        = string
}

variable "private_subnet_a_cidr" {
  description = "Private subnet A CIDR block"
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "Private subnet B CIDR block"
  type        = string
}

variable "az_a" {
  description = "Availability zone A"
  type        = string
}

variable "az_b" {
  description = "Availability zone B"
  type        = string
}

# ECR

variable "repository" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability settings"
  type        = string

  default = "MUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )

    error_message = "Image tag mutability must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}