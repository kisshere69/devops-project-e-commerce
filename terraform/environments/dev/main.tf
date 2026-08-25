data "aws_caller_identity" "current" {

}

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

  project = var.project
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  public_subnet_a_cidr = var.public_subnet_a_cidr
  az_a                 = var.az_a

  public_subnet_b_cidr = var.public_subnet_b_cidr
  az_b                 = var.az_b

  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr
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