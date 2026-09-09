resource "aws_eks_pod_identity_association" "db_migration" {
  cluster_name    = module.eks.cluster_name
  namespace       = "dev"
  service_account = "db-migration"
  role_arn        = module.rds.db_migration_role_arn
}