resource "random_password" "rds_master" {
  length  = 32
  special = true
}