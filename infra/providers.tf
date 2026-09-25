terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state criado em infra/backend
  backend "s3" {
    bucket         = "prova-devops-tfstate-6325226"
    key            = "prova-devops/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Projeto   = var.project_name
      ManagedBy = "terraform"
    }
  }
}
