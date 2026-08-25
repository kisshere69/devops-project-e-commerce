resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-vpc"
    }
  )
}