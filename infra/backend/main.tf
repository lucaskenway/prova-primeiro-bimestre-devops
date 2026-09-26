# Cria a infraestrutura do remote state (S3 + DynamoDB).
# Aplicar UMA vez, antes do projeto principal:
#   cd infra/backend && terraform init && terraform apply -var bucket_name=<nome>

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Projeto   = "prova-devops"
      ManagedBy = "terraform"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Nome globalmente único do bucket de state"
  type        = string
}

variable "lock_table_name" {
  type    = string
  default = "terraform-state-lock"
}

# O bucket é criado fora do Terraform porque, no Learner Lab, uma SCP nega
# s3:GetBucketObjectLockConfiguration e o recurso aws_s3_bucket (provider v5)
# sempre lê essa configuração, falhando em todo plan/apply. Crie antes com:
#   aws s3api create-bucket --bucket <bucket_name> --region us-east-1
# Versionamento, criptografia e bloqueio público seguem gerenciados abaixo.
data "aws_s3_bucket" "state" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = data.aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = data.aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = data.aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = var.lock_table_name
    Projeto = "prova-devops"
  }
}

output "bucket_name" {
  value = data.aws_s3_bucket.state.id
}

output "lock_table_name" {
  value = aws_dynamodb_table.lock.name
}
