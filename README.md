# API de Reservas — TechNova

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Disciplina:** DevOps — Análise e Desenvolvimento de Sistemas (2026.2)
**Professor:** Alexandre da Costa Tavares Jr

## Descrição

Projeto da Prova do Primeiro Bimestre de DevOps. A **API de Reservas** da TechNova é uma aplicação Node.js/Express que gerencia reservas (`id`, `cliente`, `data`, `status`) e as grava em um banco PostgreSQL.

O projeto passa por todas as etapas do bimestre:

- **Git:** histórico com Conventional Commits e feature branches
- **Docker:** imagem da API
- **Docker Compose:** API + PostgreSQL local subindo com um comando
- **Terraform:** VPC, Security Groups, EC2 e RDS na AWS (Learner Lab), modularizado e com remote state (S3 + DynamoDB)
- **IA como copiloto:** processo documentado em `relatorio.md`

## Estrutura

```
app/                API Node.js/Express (CRUD /reservas + /health) e Dockerfile
docker-compose.yml  API + PostgreSQL local (volume nomeado, rede bridge, healthcheck)
infra/              Terraform: módulos vpc, security-group, ec2, rds + backend/ (S3 + DynamoDB)
evidencias/         Saídas de docker build, docker compose ps e terraform plan
relatorio.md        Relatório do processo com IA
```

## Rotas da API

| Método | Rota | Descrição |
|--------|------|-----------|
| `POST` | `/reservas` | Cria reserva (`cliente` e `data` obrigatórios; `status` opcional) |
| `GET` | `/reservas` | Lista reservas |
| `GET` | `/reservas/:id` | Busca por id (404 se não existir) |
| `PUT` | `/reservas/:id` | Atualiza reserva |
| `DELETE` | `/reservas/:id` | Remove reserva |
| `GET` | `/health` | Health check (verifica conexão com o banco) |

`status` aceita `pendente` (padrão), `confirmada` ou `cancelada`. `data` em ISO 8601.

## Ambiente local

```bash
cp .env.example .env        # ajuste a senha
docker compose up -d --build
docker compose ps

curl localhost:3000/health
curl -X POST localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"cliente":"Maria Silva","data":"2026-10-01T14:00:00Z"}'
curl localhost:3000/reservas
```

## Infraestrutura AWS (Learner Lab)

Pré-requisito: credenciais do Learner Lab (AWS Details → AWS CLI) em `~/.aws/credentials`, região `us-east-1`.

```bash
# 1. Remote state (uma vez)
cd infra/backend
terraform init
terraform apply -var="bucket_name=prova-devops-tfstate-6325226"

# 2. Ajuste o nome do bucket em infra/providers.tf e crie o terraform.tfvars
cd ..
cp terraform.tfvars.example terraform.tfvars   # preencha repo_url, IP e senha
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# 3. Depois das evidências
terraform destroy
```

A EC2 usa o instance profile `LabInstanceProfile` (nenhum recurso IAM é criado). No boot ela instala Docker, clona este repositório, constrói a imagem e sobe a API apontando para o RDS.
