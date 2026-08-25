project     = "roast-co"
environment = "dev"
managed_by  = "Terraform"

cluster_name    = "roast-co-dev"
cluster_version = "1.36"

vpc_cidr = "10.0.0.0/16"

public_subnet_a_cidr = "10.0.1.0/24"
public_subnet_b_cidr = "10.0.1.0/24"

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