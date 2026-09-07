terraform {
  backend "s3" {
    bucket       = "roast-co-terraform-state-215229808174"
    key          = "environments/dev/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}