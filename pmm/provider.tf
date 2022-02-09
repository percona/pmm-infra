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
    bucket = "percona-terraform"
    key    = "pmm.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      terraform       = "true"
      iit-billing-tag = "pmm"
    }
  }
}
