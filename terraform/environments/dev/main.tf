terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source = "../../modules/eks"

  project     = var.project
  environment = var.environment

  vpc_cidr = var.vpc_cidr

  cluster_name    = aws_eks_cluster.this.name
  cluster_version = var.cluster_version

  private_subnet_ids = module.vpc.private_subnet_ids

  eks_node_group_name = var.eks_node_group_name
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type

  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  node_disk_size    = var.node_disk_size
}