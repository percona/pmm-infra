terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.2"
    }
  }
  required_version = "~> 1.6.0"

  backend "s3" {
    bucket               = "percona-terraform"
    workspace_key_prefix = "environments"
    key                  = "pmm/terraform.tfstate"
    region               = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Terraform       = "Yes"
      iit-billing-tag = "pmm"
    }
  }
}
