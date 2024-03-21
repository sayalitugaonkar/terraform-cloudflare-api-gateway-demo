terraform {
  required_version = "1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.41.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}