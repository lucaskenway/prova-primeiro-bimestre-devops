module "vpc" {
  source = "./modules/vpc"

  name                 = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_group" {
  source = "./modules/security-group"

  name              = var.project_name
  vpc_id            = module.vpc.vpc_id
  app_port          = var.app_port
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
}

module "rds" {
  source = "./modules/rds"

  name              = var.project_name
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_group.rds_sg_id
  instance_class    = var.db_instance_class
  db_name           = var.db_name
  db_user           = var.db_user
  db_password       = var.db_password
}

module "ec2" {
  source = "./modules/ec2"

  name              = var.project_name
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.ec2_sg_id
  key_name          = var.key_name
  repo_url          = var.repo_url
  app_port          = var.app_port

  db_host     = module.rds.address
  db_port     = module.rds.port
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
}
