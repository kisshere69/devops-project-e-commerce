locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
}