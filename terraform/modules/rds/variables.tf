# Default tags

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "managed_by" {
  description = "Resource management identifier"
  type        = string
}

# VPC

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}

# RDS Instance

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Master username for the PostgreSQL database"
  type        = string
}

variable "db_password" {
  description = "Master password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
}

# EKS Security Group ID

variable "eks_security_group_id" {
  description = "EKS security group allowed to access PostgreSQL"
  type        = string
}