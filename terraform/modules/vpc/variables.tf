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
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "Public subnet A CIDR block"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "Public subnet B CIDR block"
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