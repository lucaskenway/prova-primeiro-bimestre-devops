# Relatório do Processo — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Ferramenta de IA utilizada:** Claude (Claude Code, modelo Claude Opus 5.5)

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

Segui a ordem sugerida no enunciado: Git e aplicação primeiro, depois containers, depois o ambiente local com Compose e só então a AWS.
Escolhi essa ordem porque cada etapa depende da anterior. A EC2 clona o repositório do GitHub e builda a imagem pelo `Dockerfile`, então o Git e o Docker precisavam estar funcionando antes da nuvem.
Também testei a API localmente com o Compose antes de subir para a AWS, porque um erro achado no meu computador é muito mais barato e rápido de corrigir do que um erro achado depois de esperar o RDS subir.

**Aula 01 (Git e Docker):** criei o repositório público, o README com meu nome e RA e o `.gitignore` cobrindo `node_modules`, `.env`, `.terraform`, `*.tfstate` e `*.pem`.
As três etapas principais foram feitas em feature branches (`feature/api-reservas`, `feature/docker`, `feature/terraform`) e juntadas na `main` com merge. As correções feitas depois entraram como commits `fix:` direto na `main`, sempre com Conventional Commits.
Desenvolvi a API de Reservas em Node.js com Express, com o CRUD completo e a rota `/health`, gravando os dados no PostgreSQL pela biblioteca `pg`.
Em seguida criei o Dockerfile multi-stage: um estágio instala as dependências e o estágio final roda a API com o usuário `node`, que não é root.

**Aula 02 (Docker Compose e IA como copiloto):** com o Compose, subi a API junto com o PostgreSQL usando volume nomeado, rede bridge própria e healthcheck no banco. A API só inicia depois que o banco fica saudável.
Testei todas as rotas localmente com `curl`, incluindo as validações e o `/health` com o banco parado (`evidencias/testes-locais.txt`). Foi nessa aula que comecei a usar a IA como copiloto para gerar Dockerfile e Compose.

**Aula 03 (Terraform e IAM):** escrevi a infraestrutura em Terraform e respeitei a regra do Learner Lab de não criar IAM, usando o `LabInstanceProfile` já existente.

**Aula 04 (VPC e EC2):** criei a VPC com subnets públicas e privadas em duas zonas e a EC2 na subnet pública. A EC2 sobe a API no boot pelo `user_data`.

**Aula 05 (RDS e Remote State):** criei primeiro o backend de estado remoto (bucket S3 com versionamento e criptografia, mais uma tabela DynamoDB para o lock) e só depois configurei o `backend "s3"` no projeto principal. Depois veio o RDS PostgreSQL privado e criptografado.

**Aula 06 (Módulos):** separei a infraestrutura em quatro módulos (`vpc`, `security-group`, `rds` e `ec2`), ligados no `main.tf` pelos outputs de um módulo servindo de entrada para o outro, por exemplo `module.vpc.private_subnet_ids` alimentando o RDS e `module.rds.address` alimentando a EC2.

**Aula 07 (problemas complexos com IA):** no final, em vez de pedir "revise o projeto", dividi a revisão em partes (API, `/health`, Compose, AWS, IAM, Terraform, Remote State, segurança e testes) e pedi uma auditoria item por item. Também usei um roteiro de testes como verificação: cada correção só era aceita depois de passar nele.

Rodei `terraform plan`, revisei os recursos e fiz o `terraform apply` no Learner Lab. No final testei o CRUD pela URL pública da EC2 e confirmei que os dados estavam sendo gravados no RDS. Todas as evidências ficaram na pasta `evidencias/`.

## Questão 2 — O Processo com IA como Copiloto

Usei o Claude Code (modelo Claude Opus 5.5) no terminal, dentro da pasta do projeto. Ele gerou a primeira versão dos arquivos e rodou comandos, e eu conferi cada resultado com o enunciado.
Não usei o Kiro. O mais próximo do fluxo requisitos → design → tarefas foi colar partes do enunciado como requisitos e depois pedir auditorias item por item.

Os prompts principais foram:

1. Colei a estrutura de pastas exigida pelo enunciado e pedi para montar o projeto a partir dela.
2. Quando vi que a API estava com os campos errados, colei a seção "O Que Construir" do enunciado para a IA corrigir de acordo com o texto oficial.
3. Quando o `terraform apply` do backend falhou, colei a mensagem de erro do terminal (`403 AccessDenied`) e pedi a causa e a correção.
4. Pedi os comandos da AWS CLI para conferir os recursos e salvar as saídas como evidência.
5. Antes da entrega, pedi uma auditoria detalhada comparando o projeto com o enunciado, sem alterar nada, procurando "pegadinhas". Depois pedi para classificar cada problema (exigência da prova, requisito de funcionamento ou só melhoria) e só então para corrigir, testando cada correção antes de passar para a próxima e sem inventar evidências.
6. No dia da prova, pedi para rodar os testes locais, o `terraform plan`, o `apply`, gerar as evidências da nuvem e o `destroy`, acompanhando cada etapa. Também pedi que a IA não aparecesse como coautora dos commits nem no Pull Request.

A IA gerou bem a parte repetitiva: a estrutura dos módulos Terraform, o Dockerfile, o Compose e os comandos de verificação. Mas errou em vários pontos que precisei corrigir:

- A primeira versão da API usava os campos `recurso`, `data_inicio` e `data_fim`, que não eram os pedidos. Troquei para `id`, `cliente`, `data` e `status`.
- Ao reescrever o `.gitignore`, a IA removeu `*.pem` e `*.key`, que o enunciado exige. Coloquei de volta.
- O `docker-compose.yml` saiu sem a rede bridge customizada. Adicionei a rede `reservas-net`.
- A EC2 veio como `t3.micro` e sem instance profile. Mudei para `t2.micro` com o `LabInstanceProfile`.
- O filtro de AMI pegava a imagem mais recente com o nome `al2023-ami-*`, que era uma AMI de ECS com Neuron (feita para machine learning) com disco mínimo de 30 GB. O `apply` da EC2 falhou e restringi o filtro para o Amazon Linux 2023 padrão.
- O `terraform apply` do backend falhou porque o Learner Lab bloqueia a leitura da configuração de object lock do bucket (`s3:GetBucketObjectLockConfiguration`). Passei a referenciar o bucket com `data "aws_s3_bucket"` e mantive versionamento, criptografia e bloqueio público no Terraform.

A auditoria final encontrou erros que pareciam corretos à primeira vista:

- A validação da data usava `new Date(data)`, que aceitava `01/10/2026` e gravava como 10 de janeiro. Datas como `2026-02-30` geravam erro 500. Troquei por uma validação ISO 8601 de verdade, que responde 400.
- Se o banco caísse logo depois de uma requisição, a API inteira travava, porque o pool de conexões não tratava o evento de erro, e o `/health` nem respondia. Adicionei o tratamento e um timeout. Agora o `/health` responde 503 e a API volta sozinha quando o banco volta.
- O `PUT` sem o campo `status` voltava a reserva para `pendente`. Agora ele mantém o status atual.
- O `user_data` usava `set -x`, que gravaria a senha do RDS no log de boot da EC2. Removi o `-x`.
- O README não tinha o passo de criar o bucket pela CLI, então quem seguisse o README não conseguiria subir o backend.
- O checklist de entrega estava marcado com `terraform validate`, mas não havia evidência disso. Gerei `evidencias/terraform-validate.txt`.

A própria IA também errou parcialmente: na auditoria ela disse que a minha frase "o endereço do RDS nem resolve" provavelmente estava errada. No teste real, o DNS do meu computador realmente não resolvia o nome (ele bloqueia respostas com IP privado), mas pelo DNS público do Google o nome resolvia para `10.0.x.x`, um IP privado. Os dois estavam parcialmente certos, e só o teste mostrou o motivo real. Reescrevi a explicação com base no teste (`evidencias/rds.txt`).

Comparando com fazer manualmente, a IA economizou muito tempo escrevendo Terraform e os comandos da AWS CLI, que eu levaria horas para montar consultando a documentação.
Ela atrapalhou quando não conhecia as restrições do Learner Lab (SCP do S3, AMI errada) e quando entregava algo que funcionava no caso feliz mas falhava no caso de erro, como a data e a queda do banco.
O controle de permissões do Claude Code também ajudou: ele bloqueou a IA de rodar `terraform apply` sozinha, então eu mesmo rodei, revisei o plano e confirmei.
Aprendi que a IA ajuda bastante, mas não conhece as restrições do ambiente e às vezes ignora requisitos. Por isso todo resultado precisa ser validado com testes, não só lido.

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

```
Internet
   │ porta 3000 (API) / 22 (só meu IP)
   ▼
VPC 10.0.0.0/16 (us-east-1)
├── Subnets públicas (us-east-1a, us-east-1b) ── rota para o Internet Gateway
│     └── EC2 t2.micro (Docker + API)  [SG da EC2]
│             │ porta 5432
│             ▼
└── Subnets privadas (us-east-1a, us-east-1b) ── sem rota para a internet
      └── RDS PostgreSQL db.t3.micro  [SG do RDS: 5432 só do SG da EC2]

Remote state: S3 (versionado + criptografado) + DynamoDB (lock)
```

A VPC usa o bloco `10.0.0.0/16` e tem duas subnets públicas e duas privadas, distribuídas em duas zonas de disponibilidade. As subnets públicas têm rota para o Internet Gateway; as privadas não têm saída para a internet.

A EC2 `t2.micro` fica na subnet pública porque precisa ser acessada pelos usuários da API na porta 3000. No boot ela também precisa da internet para instalar o Docker, clonar o repositório do GitHub e baixar a imagem do Node.
O Security Group da EC2 libera só a porta 3000 para a API e a porta 22 apenas para o meu IP (`/32`).

O RDS PostgreSQL `db.t3.micro` fica nas subnets privadas porque ninguém de fora precisa falar diretamente com o banco: só a API. Ele usa o `db_subnet_group_name` com as subnets privadas, `publicly_accessible = false` e `storage_encrypted = true`.
O Security Group do RDS só aceita a porta 5432 vindo do Security Group da EC2, e não de um bloco de IPs. Assim, mesmo sabendo o endereço do banco, não dá para conectar de fora da VPC: ele não tem IP público, as subnets não têm rota para a internet e o firewall só aceita a EC2.
O disco da EC2 também é criptografado e o metadata exige IMDSv2.

Sobre o IAM: o Learner Lab não deixa criar usuários, grupos nem roles. Em vez de criar uma role para a EC2, passei o instance profile pré-existente `LabInstanceProfile` no atributo `iam_instance_profile` do módulo `ec2`. Esse profile aponta para a `LabRole`, e no `terraform plan` aparece `iam_instance_profile = "LabInstanceProfile"`. Nenhum recurso `aws_iam_*` foi criado.

O Learner Lab exigiu alguns ajustes em relação ao que foi ensinado:

- **Credenciais temporárias:** elas vêm com session token e expiram. Quando o token expirava, o Terraform e a AWS CLI davam `ExpiredToken`, e eu precisava reiniciar o Lab e atualizar o `~/.aws/credentials`. Também aprendi a configurar essas chaves direto no terminal (`aws configure`) em vez de colar no chat da IA.
- **Região:** sempre `us-east-1`, fixada no provider e no backend.
- **IAM:** não é possível criar IAM, então usei o `LabInstanceProfile` e o key pair `vockey`, que já existem no Lab.
- **SCP:** algumas ações são bloqueadas, como a leitura de object lock do S3. Por isso o bucket é criado pela CLI e o resto do backend pelo Terraform.
- **Sessão expirando e troca de conta:** no dia da prova, a sessão do Lab expirou no meio do trabalho e as credenciais foram canceladas (a AWS passou a responder com uma política `voc-cancel-cred`). Precisei refazer o ciclo completo em outra conta do Learner Lab. Como nomes de bucket S3 são únicos no mundo inteiro e `prova-devops-tfstate-6325226` já existia na conta antiga, criei o bucket `prova-devops-tfstate-6325226-b` e passei o nome só na hora do `terraform init -backend-config="bucket=..."`, sem alterar o código. As evidências dessa subida estão em `evidencias/subida-conta-377871695195/`.

A senha do banco não fica no código: ela vai no `terraform.tfvars`, que está no `.gitignore`, e a variável é marcada como `sensitive`.
Todos os recursos recebem tags com o nome do projeto e `ManagedBy = terraform`, pelo `default_tags` do provider.

## Questão 4 — Validação e Responsabilidade

Mesmo com a IA gerando o código, a responsabilidade pelo que vai para a nuvem é minha. Por isso segui um checklist antes e depois do deploy:

1. Rodei `terraform fmt` e `terraform validate` para checar a sintaxe (`evidencias/terraform-validate.txt`).
2. Li o `terraform plan` recurso por recurso antes de confirmar o `apply`.
3. Conferi que nenhum recurso `aws_iam_*` estava sendo criado, porque o Learner Lab não permite.
4. Conferi que o RDS não é público e está criptografado (`evidencias/rds.txt`).
5. Conferi que o SSH não está aberto para `0.0.0.0/0`, só para o meu IP, e que a porta 5432 só aceita o SG da EC2 (`evidencias/security-groups.txt`).
6. Conferi que `.env`, `*.tfstate`, `*.tfvars` e `*.pem` estão no `.gitignore` e nunca foram commitados.
7. Conferi o remote state na AWS: bucket versionado e criptografado, mais a tabela de lock (`evidencias/remote-state.txt`).
8. Testei todas as rotas do CRUD, primeiro localmente com o Compose, incluindo dados inválidos e o banco parado (`evidencias/testes-locais.txt`), e depois na nuvem (`evidencias/crud-nuvem.txt`).
9. Quando algo falhou (o bucket S3 e a AMI), li a mensagem de erro para entender a causa antes de aceitar a correção.
10. Depois de capturar as evidências, rodei `terraform destroy` para não gastar os créditos do Learner Lab (`evidencias/terraform-destroy.txt` e `evidencias/subida-conta-377871695195/terraform-destroy.txt`). Uma segunda subida, feita na conta antiga só para tirar prints, ficou sem `destroy`, porque a sessão do Lab expirou antes. Ela precisa ser destruída quando eu tiver acesso de novo àquela conta.

Se eu tivesse aceitado o código da IA sem revisar, os problemas teriam sido reais. A EC2 não subiria por causa da AMI errada. Uma chave `.pem` poderia ir parar no GitHub porque a IA tirou o `*.pem` do `.gitignore`.
A API aceitaria `01/10/2026` e gravaria a reserva em 10 de janeiro, um erro silencioso que o cliente só descobriria no dia errado. A API cairia toda vez que o banco reiniciasse, e a senha do RDS ficaria no log de boot da EC2.
Vários desses erros passavam no teste mais simples (criar uma reserva válida e listar) e só apareceram quando testei os casos de erro.

Ler o `plan` antes de aplicar também evitou um erro no dia da prova. Durante o `apply`, o computador entrou em suspensão e o Terraform ficou travado em "Still creating" no RDS, mesmo com o banco já `available` na AWS. Interrompi com Ctrl+C, que salva o state e libera o lock, em vez de forçar o destravamento. O `plan` seguinte mostrou que o Terraform ia apagar e recriar o RDS, porque ele ficou marcado como `tainted`. Como o banco estava saudável, usei `terraform untaint` e só apliquei depois de conferir que o plano era exatamente "1 to add", ou seja, só a EC2 (`evidencias/subida-conta-377871695195/terraform-apply.txt`). Se eu tivesse rodado o `apply` sem ler o plano, teria perdido mais uns 10 minutos recriando o banco.

A evolução Git → Docker → Terraform → Modules me preparou para usar a IA com responsabilidade.
O Git me deu um histórico em que cada mudança da IA vira um diff que eu leio e posso desfazer.
O Docker garante que o que testei no meu computador é o mesmo que roda na EC2.
O Terraform transforma a infraestrutura em código que eu revejo no `plan` antes de criar qualquer coisa.
Os módulos dividem esse código em partes pequenas, que dá para revisar uma de cada vez. É a mesma ideia de dividir um problema grande para a IA, da Aula 07.

A principal lição é que a IA é um copiloto: ela escreve rápido, mas quem valida, entende e responde pelo resultado sou eu.
