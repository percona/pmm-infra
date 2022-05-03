terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
  required_version = "~> 1.1.5"

  backend "s3" {
    bucket = "pmm-tutorial-pl22"
    key    = "pmm.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = "us-west-1"
  default_tags {
    tags = {
      Event           = "pl22"
      Terraform       = "Yes"
      iit-billing-tag = "michael.coburn@percona.com"
    }
  }
}
