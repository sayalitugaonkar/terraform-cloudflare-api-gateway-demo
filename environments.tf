### To have prod environment match the staging environment, I would prefer using workspaces and declaring workspace specific values here

locals {
  environments = {
    prod = {
      route53_domain = "example.com"
      vpc_name       = "prod_vpc"
      subnets = {
        "subnet-1" = { cidr_block = "10.0.1.0/24", availability_zone = "ap-south-1a", tag_name = "private-subnet-1a" }
      }
      subnet_pub = {
        "subnet-1" = { cidr_block = "10.0.4.0/24", availability_zone = "ap-south-1a", tag_name = "public-subnet-1a" }
      }
    }
    staging = {
      route53_domain = "example-stg.com"
      vpc_name       = "stg_vpc"
      subnets = {
        "subnet-1" = { cidr_block = "10.0.1.0/24", availability_zone = "ap-south-1a", tag_name = "private-subnet-1a" }
      }
      subnet_pub = {
        "subnet-1" = { cidr_block = "10.0.4.0/24", availability_zone = "ap-south-1a", tag_name = "public-subnet-1a" }
      }
    }
  }
  env = lookup(local.environments, terraform.workspace)
}