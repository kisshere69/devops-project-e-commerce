project     = "roast-co"
environment = "dev"
managed_by  = "Terraform"

cluster_name    = "roast-co-dev"
cluster_version = "1.36"

vpc_cidr = "10.0.0.0/16"

eks_node_group_name = "general"
node_instance_types = ["t3.small"]
node_capacity_type  = "SPOT"
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
node_disk_size      = 20