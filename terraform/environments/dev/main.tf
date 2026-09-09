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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
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

module "ecr_db_migration" {
  source = "../../modules/ecr"

  project     = var.project
  environment = var.environment
  managed_by  = var.managed_by

  repository           = var.db_migration_repository
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

module "github-oidc" {
  source       = "../../modules/github-oidc"
  github_repo  = var.github_repo
  cluster_name = var.cluster_name
  cluster_arn  = module.eks.cluster_arn

  github_oidc_subject      = var.github_oidc_subject
  github_oidc_provider_arn = var.github_oidc_provider_arn
  repository               = var.repository
  db_migration_repository  = var.db_migration_repository
  project                  = var.project
  environment              = var.environment
  managed_by               = var.managed_by
  region                   = var.region

  depends_on = [
    module.eks
  ]
}

module "rds" {
  source = "../../modules/rds"

  project     = var.project
  environment = var.environment
  managed_by  = var.managed_by

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  eks_security_group_id = module.eks.cluster_security_group_id

  db_name     = var.db_name
  db_username = var.db_username

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
}