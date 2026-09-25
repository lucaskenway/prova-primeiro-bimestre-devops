variable "name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "key_name" {
  description = "Key pair para SSH (opcional)"
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Instance profile pré-existente do Learner Lab"
  type        = string
  default     = "LabInstanceProfile"
}

variable "repo_url" {
  description = "URL do repositório Git clonado no boot"
  type        = string
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
