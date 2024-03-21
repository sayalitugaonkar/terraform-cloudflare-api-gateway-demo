### We are creating VPC and subnet via a module for both staging and prod

module "vpc" {
  count    = terraform.workspace == "staging" || terraform.workspace == "prod" ? 1 : 0
  source   = "./modules/vpc-module"
  vpc_name = local.env.vpc_name

  env_module = local.env
}