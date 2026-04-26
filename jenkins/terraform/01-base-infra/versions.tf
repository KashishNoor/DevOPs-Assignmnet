terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "kashish-devops-tfstate-188876037443"
    key          = "assignment-4/base-infra/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
