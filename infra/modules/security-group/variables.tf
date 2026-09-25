variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs autorizados a acessar SSH (use seu IP/32)"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
