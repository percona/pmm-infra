terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }
  required_version = "~> 1.2.8"

  backend "s3" {
    bucket = "percona-terraform"
    key    = "pmmdemo.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Terraform       = "Yes"
      iit-billing-tag = "pmm-demo"
    }
  }
}

provider "azurerm" {
  alias = "demo"
  features {}
}
