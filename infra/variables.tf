variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "prova-devops"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "ssh_allowed_cidrs" {
  description = "Use seu IP público com /32"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = null
}

variable "repo_url" {
  description = "URL pública do repositório com o código da API"
  type        = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "reservas"
}

variable "db_user" {
  type    = string
  default = "reservas"
}

variable "db_password" {
  description = "Senha do RDS (passe via TF_VAR_db_password ou terraform.tfvars)"
  type        = string
  sensitive   = true
}
