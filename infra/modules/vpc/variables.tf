variable "name" {
  description = "Prefixo dos recursos"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "Mínimo 2 (em AZs diferentes) para o DB subnet group do RDS"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
