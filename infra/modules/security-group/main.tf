# SG da EC2: HTTP da API aberto, SSH restrito
resource "aws_security_group" "ec2" {
  name        = "${var.name}-ec2-sg"
  description = "Acesso a API de Reservas"
  vpc_id      = var.vpc_id

  ingress {
    description = "API"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH só é liberado se algum CIDR for informado (use seu IP/32)
  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-ec2-sg" })
}

# SG do RDS: PostgreSQL aceito somente a partir do SG da EC2
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "PostgreSQL acessivel apenas pela EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL vindo da EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}
