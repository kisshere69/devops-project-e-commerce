resource "aws_eks_pod_identity_association" "db_migration" {
  cluster_name    = module.eks.cluster_name
  namespace       = "dev"
  service_account = "db-migration"
  role_arn        = module.rds.db_migration_role_arn
}

resource "aws_eks_pod_identity_association" "app" {
  cluster_name    = module.eks.cluster_name
  namespace       = "dev"
  service_account = "roast-co-app"
  role_arn        = module.rds.app_role_arn
}