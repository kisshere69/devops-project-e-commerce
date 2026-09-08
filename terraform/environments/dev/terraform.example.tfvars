project     = "roast-co"
environment = "dev"
managed_by  = "Terraform"
region      = "eu-central-1"

cluster_name    = "roast-co-dev"
cluster_version = "1.36"

vpc_cidr = "10.0.0.0/16"

public_subnet_a_cidr = "10.0.1.0/24"
public_subnet_b_cidr = "10.0.2.0/24"

private_subnet_a_cidr = "10.0.11.0/24"
private_subnet_b_cidr = "10.0.12.0/24"

az_a = "eu-central-1a"
az_b = "eu-central-1b"

eks_node_group_name = "general"
node_instance_types = ["t3.small"]
node_capacity_type  = "SPOT"
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
node_disk_size      = 20

repository              = "roast-co-app"
db_migration_repository = "roast-co-db-migration"
image_tag_mutability    = "MUTABLE"
scan_on_push            = true

cluster_admin_principal_arn = "arn:aws:iam::<ACCOUNT_ID>:user/terraform-user"

domain_name               = "roast-and-co.online"
subject_alternative_names = ["www.roast-and-co.online"]
cloudflare_zone_id        = "value"

github_repo              = "kisshere69/devops-project-e-commerce"
github_oidc_provider_arn = "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
github_oidc_subject      = "repo:kisshere69/devops-project-e-commerce:*"

db_name           = "coffee_shop"
db_username       = "roast_admin"
instance_class    = "db.t3.micro"
allocated_storage = 20