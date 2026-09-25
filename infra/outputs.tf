output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "api_url" {
  value = "http://${module.ec2.public_dns}:${var.app_port}"
}

output "rds_endpoint" {
  value = module.rds.endpoint
}
