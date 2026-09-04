data "aws_caller_identity" "current" {

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr

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

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  private_subnet_ids = module.vpc.private_subnet_ids

  eks_node_group_name = var.eks_node_group_name
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type

  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  node_disk_size    = var.node_disk_size

  cluster_admin_principal_arn = var.cluster_admin_principal_arn
}

module "ecr" {
  source = "../../modules/ecr"

  project     = var.project
  environment = var.environment
  managed_by  = var.managed_by

  repository           = var.repository
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
}

module "alb-controller" {
  source = "../../modules/alb-controller"

  project      = var.project
  environment  = var.environment
  managed_by   = var.managed_by
  cluster_name = module.eks.cluster_name
}

module "acm-certificate" {
  source = "../../modules/acm-certificate"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  cloudflare_zone_id        = var.cloudflare_zone_id
}