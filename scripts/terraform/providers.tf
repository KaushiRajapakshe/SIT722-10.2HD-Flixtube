# Initialises Terraform providers and sets their version numbers.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
  }

  required_version = ">= 1.5.6"
}

provider "aws" {
  region = var.aws_region
}
