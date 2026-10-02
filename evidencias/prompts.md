# Registro de Prompts — uso da IA como copiloto

**Ferramenta:** Claude Code (modelo Claude Opus 5.5), no terminal, dentro da pasta do projeto.  
**Fonte:** histórico das sessões do Claude Code deste projeto. Horários em BRT (UTC−3).

Os prompts curtos estão exatamente como foram digitados. Trechos longos colados (partes do enunciado e saídas do terminal) aparecem resumidos entre colchetes.
As credenciais AWS coladas no chat foram omitidas por segurança. Mensagens de aprovação de comandos não aparecem.
A conversa completa, com as respostas da IA, está em [`conversa-completa.md`](conversa-completa.md).

## Sessão 1 — construção do projeto

1. **24/09 21:07** — [colou a estrutura de pastas exigida pelo enunciado para a IA montar o projeto]
2. **24/09 21:42** — agora vc vai gradar os historo do que eu fiz

## Sessão 2 — AWS, evidências e relatório (26/09, retomada em 30/09)

1. **26/09 18:10** — [colou a estrutura de pastas do enunciado] ta assim
2. **26/09 18:15** — [credenciais AWS coladas — omitidas por segurança]
3. **26/09 18:16** — pode gerar
4. **26/09 18:19** — pode fazer
5. **26/09 18:42** — me manda os comandados e abri o vs code no terminal
6. **26/09 18:44** — [colou a seção "O Que Construir" do enunciado (campos id, cliente, data, status e as rotas obrigatórias) para corrigir a API]
7. **26/09 18:49** — [colou o erro do terminal: `api error AccessDenied ... StatusCode: 403` ao aplicar o backend S3]
8. **26/09 18:49** — pode fazer os dois
9. **26/09 18:55** — [colou a saída do terminal: `terraform apply` pedindo `var.bucket_name`]
10. **26/09 18:56** — [colou a saída do terminal: `cd infra` → `No such file or directory`]
11. **26/09 18:57** — [colou a saída do `terraform plan`: `Plan: 17 to add, 0 to change, 0 to destroy`]
12. **26/09 19:07** — [colou a saída do `terraform apply` com o RDS em criação (`Still creating... [06m20s elapsed]`)]
13. **26/09 19:14** — [colou a saída do `terraform apply` com a EC2 criada]
14. **26/09 19:17** — pode criar o relatro simples
15. **26/09 20:14** — ve o que ja tem e marcar x no espaco " [colou o modelo do entrega.md do enunciado] "
16. **26/09 20:16** — https://github.com/lucaskenway/prova-primeiro-bimestre-devops.git
17. **26/09 20:17** — nao fazer ainda eu quero que vc manda os comandos para eu ve la na aws
18. **26/09 20:22** — pode colocar isso em como txt tbm " API rodando na EC2 curl http://44.197.186.217:3000/health curl http://44.197.186.217:3000/reservas "
19. **26/09 20:23** — pode colocar isso em como txt tbm " [colou a saída dos comandos da AWS CLI no terminal do Learner Lab] "
20. **26/09 20:25** — [Image #14] ,[Image #15],[Image #16]
21. **26/09 20:28** — fazer o ultimo terraform destroy e o resoltado em txt
22. **26/09 20:34** — deixa no esquema mais nao manda pq eu tenho que manda no dia da prova e tbm eu vou refazer no dia para ve se ta certo
23. **30/09 19:28** — claude eu quero que vc colocar o promt tambem na evidencias claude --resume cd1f5a3c-02d5-4823-b2ef-e442e1594120

## Sessão 3 — retomada e pegadinhas

1. **28/09 18:59** — claude --resume cd1f5a3c-02d5-4823-b2ef-e442e1594120
2. **28/09 18:59** — so quero vc puxa esta converssa
3. **28/09 19:01** — vc tinha falando que tinha uma pegadia tbm
4. **28/09 19:03** — qual sao este pegadinhas pode me fala d novpo
5. **28/09 19:06** — no dia vc falou que timnha pegadinhas quando vc leu o devops_20262/provas /prova-primeiro-bimestre.md

## Sessão 4 — auditoria, correções, deploy e entrega (30/09 e 01/10)

1. **30/09 21:23** — Faça uma auditoria detalhada, mas NÃO altere nenhum arquivo. *(prompt completo abaixo)*

   <details><summary>Ver prompt completo</summary>

   ```text
   Faça uma auditoria detalhada, mas NÃO altere nenhum arquivo.
   
   Compare o projeto com o enunciado da prova e procure principalmente estas pegadinhas:
   
   1. API
   
   - POST /reservas deve exigir cliente e data.
   - status é opcional e deve ter padrão "pendente".
   - status permitido somente: pendente, confirmada, cancelada.
   - data deve aceitar/validar ISO 8601.
   - GET /reservas deve buscar no PostgreSQL.
   - GET /reservas/:id deve retornar 404 quando não existir.
   - PUT deve atualizar no PostgreSQL.
   - DELETE deve remover no PostgreSQL.
   - Nenhuma rota pode usar array, variável global ou memória como banco.
   
   2. /health
   
   - Deve testar de verdade a conexão com PostgreSQL.
   - Não pode simplesmente retornar "OK" sem consultar/verificar o banco.
   - Verifique também o comportamento quando o banco estiver indisponível.
   
   3. Docker Compose
   
   - API e PostgreSQL devem estar no mesmo ambiente.
   - PostgreSQL deve usar volume nomeado.
   - Deve existir rede bridge customizada.
   - PostgreSQL deve ter healthcheck.
   - depends_on deve esperar o banco ficar saudável.
   - Variáveis de banco devem vir de configuração/env, sem senha real versionada.
   
   4. AWS
   
   - A API da EC2 deve realmente conectar no RDS.
   - O RDS deve ser PostgreSQL db.t3.micro.
   - O RDS deve estar em subnets privadas.
   - publicly_accessible deve ser false.
   - storage_encrypted deve ser true.
   - O RDS deve aceitar 5432 somente do Security Group da EC2.
   - Não pode existir regra 5432 aberta para 0.0.0.0/0.
   - A EC2 deve ser t2.micro e ficar em subnet pública.
   - A EC2 deve conseguir acessar o RDS pela rede privada.
   
   5. EC2 / user_data
      Verifique se o user_data realmente:
   
   - instala Docker;
   - inicia/habilita Docker;
   - clona o repositório correto;
   - constrói a imagem da API;
   - configura as variáveis de conexão com o RDS;
   - inicia a API;
   - expõe a porta 3000;
   - faz a API ficar disponível após o boot.
   
   Não aceite apenas comentários ou textos dizendo que isso acontece. Confirme no código.
   
   6. IAM / Learner Lab
   
   - Não pode criar usuário IAM.
   - Não pode criar grupo IAM.
   - Não pode criar role IAM própria.
   - Deve usar LabRole/LabInstanceProfile quando necessário.
   
   7. Terraform
   
   - VPC deve ter subnets públicas e privadas em 2 AZs.
   - Os módulos devem realmente ser usados.
   - Deve existir comunicação por outputs → inputs entre módulos.
   - Security Group da EC2 deve permitir somente o necessário.
   - RDS deve depender corretamente das subnets privadas e do SG.
   - Tags devem estar nos recursos exigidos.
   - Outputs devem fornecer IP da EC2, endpoint do RDS e URL da API.
   
   8. Remote State
   
   - Deve existir S3 para o state.
   - S3 deve ter versionamento.
   - S3 deve ter criptografia.
   - DynamoDB deve ser usado para locking conforme exigido pela prova.
   - O backend deve estar configurado corretamente no Terraform principal.
   - O backend deve ser criado antes de o projeto principal tentar utilizá-lo.
   
   9. Segurança
      Procure:
   
   - senhas dentro do código;
   - senhas dentro do Git;
   - .env versionado;
   - terraform.tfvars versionado;
   - state versionado;
   - *.pem versionado;
   - portas desnecessariamente abertas;
   - recursos IAM proibidos.
   
   10. Testes
       Verifique se existem evidências reais para:
   
   - docker build;
   - docker compose ps;
   - /health;
   - CRUD local;
   - terraform validate;
   - terraform plan;
   - infraestrutura AWS;
   - API EC2 → RDS;
   - CRUD usando RDS;
   - terraform destroy.
   
   IMPORTANTE:
   Não altere nada.
   Não invente testes.
   Não considere um requisito atendido apenas porque existe no README.
   Analise os arquivos reais e o código.
   
   No final, responda exatamente nesta estrutura:
   
   OK
   
   Requisitos comprovadamente atendidos.
   
   ERROS
   
   Problemas encontrados.
   
   FALTAS
   
   Requisitos que não existem.
   
   PEGADINHAS
   
   Possíveis problemas que parecem corretos, mas não atendem completamente ao enunciado.
   
   NÃO COMPROVADO
   
   Itens que existem, mas ainda precisam ser testados.
   
   PRIORIDADE
   
   Liste em ordem o que precisa ser corrigido/testado primeiro.
   
   Para cada problema, informe o arquivo e, se possível, a linha ou bloco responsável.
   ```

   </details>

2. **30/09 21:29** — Agora analise somente os itens encontrados na auditoria. *(prompt completo abaixo)*

   <details><summary>Ver prompt completo</summary>

   ```text
   Agora analise somente os itens encontrados na auditoria.
   
   Para cada item de ERROS, FALTAS, PEGADINHAS e NÃO COMPROVADO, diga:
   
   1. É exigência explícita da prova?
   2. É requisito implícito necessário para funcionar?
   3. É apenas melhoria de segurança/qualidade?
   4. Pode prejudicar a nota se não corrigir?
   5. Precisa gerar nova evidência?
   
   Não altere nenhum arquivo ainda.
   
   Dê prioridade principalmente para:
   
   * ISO 8601;
   * /health com banco indisponível;
   * PUT alterando status para pendente;
   * user_data e senha;
   * Remote State S3 + DynamoDB;
   * Terraform validate;
   * evidências locais;
   * evidências AWS;
   * GitHub atualizado antes do EC2 clonar.
   
   No final, faça uma lista:
   CRÍTICO → corrigir antes da prova
   IMPORTANTE → corrigir se necessário
   OPCIONAL → melhoria, não requisito
   
   Não invente exigências que não estão no enunciado.
   ```

   </details>

3. **30/09 21:31** — Agora analise os itens encontrados na auditoria e CORRIJA os problemas encontrados. *(prompt completo abaixo)*

   <details><summary>Ver prompt completo</summary>

   ```text
   Agora analise os itens encontrados na auditoria e CORRIJA os problemas encontrados.
   
   Priorize os problemas que podem afetar a nota ou o funcionamento da prova.
   
   Antes de alterar qualquer arquivo:
   
   1. Leia os arquivos envolvidos.
   2. Compare com o enunciado da prova.
   3. Confirme se o problema realmente existe.
   4. Não corrija melhorias que não sejam necessárias sem antes explicar.
   
   Prioridade:
   
   1. ISO 8601
   2. `/health` funcionando corretamente quando o banco estiver indisponível
   3. PUT não alterar indevidamente o status para `pendente`
   4. `user_data` e exposição da senha
   5. Remote State S3 + DynamoDB
   6. `terraform validate`
   7. Evidências dos testes locais
   8. Evidências dos testes AWS
   9. CRUD na nuvem
   10. README e instruções de execução
   11. Git/GitHub, commits e branch/merge
   12. localização/formato do `ENTREGA.md`
   
   Para cada problema:
   
   * explique rapidamente o que está errado;
   * diga se é exigência da prova, requisito de funcionamento ou melhoria;
   * corrija somente se fizer sentido;
   * teste a correção;
   * confira se a correção não quebrou outra parte;
   * registre o resultado.
   
   IMPORTANTE:
   
   * Não invente requisitos.
   * Não remova funcionalidades existentes sem necessidade.
   * Não altere infraestrutura AWS destrutivamente sem me avisar.
   * Não execute `terraform destroy` agora.
   * Não exponha senhas, tokens ou credenciais nas evidências.
   * Não invente evidências.
   * Se algo não puder ser testado, marque como `NÃO TESTADO`.
   * Preserve o funcionamento local e em AWS.
   * Não faça várias mudanças grandes sem testar entre elas.
   
   Depois das correções, faça uma nova auditoria completa.
   
   No final mostre:
   
   1. Problemas encontrados.
   2. Problemas corrigidos.
   3. Arquivos alterados.
   4. Testes executados e resultados.
   5. Evidências novas geradas.
   6. Problemas que continuam pendentes.
   7. Melhorias que NÃO foram feitas por não serem exigências da prova.
   8. Status final de cada requisito: `ATENDIDO`, `CORRIGIDO`, `PENDENTE` ou `NÃO TESTADO`.
   
   Não avance para uma nova alteração enquanto a anterior não tiver sido testada.
   ```

   </details>

   - *Durante a execução deste prompt:* [credenciais AWS coladas — omitidas por segurança]

4. **30/09 21:46** — Agora NÃO faça alterações no código. *(prompt completo abaixo)*

   <details><summary>Ver prompt completo</summary>

   ```text
   Agora NÃO faça alterações no código.
   
   Faça uma auditoria final somente dos pontos que ainda podem impedir a entrega da prova.
   
   Verifique no repositório:
   
   1. O requisito exato para o `ENTREGA.md` e se sua localização atual está correta.
   2. Quantidade e formato dos commits.
   3. Feature branch e merge.
   4. Se o `.gitignore` impede `.env`, `.terraform`, `.tfstate` e `.pem`.
   5. Se nenhum segredo está versionado.
   6. Se o README está coerente com o projeto atual.
   7. Se o `relatorio.md` documenta corretamente o uso da IA e os testes realizados.
   8. Se todas as evidências obrigatórias estão presentes.
   9. Se existe alguma evidência que ainda esteja desatualizada depois das correções.
   10. Se o projeto está pronto para:
       commit → push → terraform apply → testes AWS → evidências → destroy.
   
   NÃO corrija nada.
   
   Para cada item, informe:
   
   * ATENDIDO
   * PRECISA CORREÇÃO
   * NÃO TESTADO
   * NÃO É EXIGÊNCIA
   
   Se encontrar alguma divergência no `ENTREGA.md`, README, relatório ou evidências, mostre exatamente o que está errado e qual requisito do enunciado está relacionado.
   
   No final, gere um checklist:
   
   BLOQUEADORES antes do push
   BLOQUEADORES antes do terraform apply
   BLOQUEADORES antes da entrega
   ITENS OPCIONAIS
   
   Não invente requisitos.
   ```

   </details>

5. **30/09 21:50** — Agora pare as alterações e faça somente uma auditoria final antes do primeiro commit/push. *(prompt completo abaixo)*

   <details><summary>Ver prompt completo</summary>

   ```text
   Agora pare as alterações e faça somente uma auditoria final antes do primeiro commit/push.
   
   NÃO altere nenhum arquivo.
   
   Verifique no projeto atual:
   
   1. `ENTREGA.md`
   
      * confira a localização exigida pelo enunciado;
      * confira o nome correto do arquivo;
      * não altere ainda, apenas informe se está correto.
   
   2. Git
   
      * quantidade de commits;
      * Conventional Commits;
      * feature branch;
      * merge realizado;
      * branch atual;
      * diferenças entre local e origin;
      * arquivos modificados e não commitados.
   
   3. Segurança
   
      * `.env` ignorado;
      * `terraform.tfvars` ignorado;
      * `.terraform` ignorado;
      * `*.tfstate` ignorado;
      * `*.pem` ignorado;
      * nenhum segredo versionado.
   
   4. Evidências
   
      * liste todas as evidências existentes;
      * diga quais estão atualizadas após as últimas correções;
      * identifique qualquer evidência desatualizada ou faltante;
      * não invente evidências.
   
   5. README
   
      * confira se os comandos ainda correspondem ao projeto atual;
      * confira principalmente o procedimento do Remote State;
      * informe qualquer comando incorreto ou faltante.
   
   6. `relatorio.md`
   
      * confira se documenta o uso da IA;
      * confira se registra os testes e correções relevantes;
      * informe o que está faltando, sem alterar.
   
   7. Infraestrutura
   
      * confira se Terraform está formatado;
      * confira se `terraform validate` já foi executado;
      * confira se módulos, outputs, variáveis e backend estão coerentes;
      * NÃO execute apply ou destroy.
   
   No final, responda exatamente nesta estrutura:
   
   ### BLOQUEADORES ANTES DO PUSH
   
   * ...
   
   ### BLOQUEADORES ANTES DO TERRAFORM APPLY
   
   * ...
   
   ### BLOQUEADORES ANTES DA ENTREGA
   
   * ...
   
   ### NÃO SÃO BLOQUEADORES
   
   * ...
   
   ### STATUS
   
   PRONTO PARA COMMIT/PUSH: SIM ou NÃO
   
   Não faça nenhuma alteração.
   Não faça commit.
   Não faça push.
   Não execute terraform apply.
   Não execute terraform destroy.
   ```

   </details>

6. **30/09 21:52** — *(reenviou o mesmo prompt do item anterior, depois de interromper um comando)*
7. **30/09 21:58** — me manda os comandados para eu ve na aws
8. **30/09 22:00** — [credenciais AWS coladas — omitidas por segurança]
9. **30/09 22:02** — sim, salva a evidência
10. **30/09 22:03** — agora me ajuda a completar o relatorio.md
11. **30/09 22:08** — agora me ajuda a criar o entrega.md
12. **30/09 22:10** — pode colocar a data de 01/10
13. **30/09 22:12** — posso ve se a aws ta la
14. **30/09 22:18** — agora nao so amanha
15. **30/09 22:19** — valeu, amanha eu te chamo
16. **30/09 22:19** — ah vc fazer os um relatrio de promt ?
17. **30/09 22:21** — e de todas a nossa coversa
18. **30/09 22:22** — e de todas a nossa coversa, so dessa coversa da prova-primeiro-bimestre-devops desse do primoro dia
19. **01/10 13:27** — [credenciais AWS coladas — omitidas por segurança]
20. **01/10 13:31** — pode fazer o teste
21. **01/10 13:37** — pode fazer ve as evidecas e ve qual falta e coloca em txt e dps me fala os comandos para ve se ta na aws
22. **01/10 13:42** — [colou a saída do terminal do Learner Lab: só o bucket S3 e a tabela DynamoDB apareciam, o RDS ainda não existia e o `tee` falhou por não haver a pasta `evidencias/` lá]
23. **01/10 13:42** — pode fazer o terraform plan
24. **01/10 13:44** — pode me manda para ve eu ve la no aws
25. **01/10 13:45** — entao pode fazer terraform apply
26. **01/10 13:47** — [Image #3] mais quando vc eu quero que vc nao aparecera
27. **01/10 13:49** — entao pode fazer terraform apply
28. **01/10 13:49** — me avisa quando terminar o apply
29. **01/10 13:50** — ja terminou o apply?
30. **01/10 13:52** — ja terminou?
31. **01/10 13:54** — ja terminou o apply?
32. **01/10 13:54** — ja terminou o apply?
33. **01/10 18:54** — [credenciais AWS coladas — omitidas por segurança]
34. **01/10 18:55** — pode fazer o terraform destroy
35. **01/10 18:57** — mantem os prints de hoje
36. **01/10 18:58** — colocar de hj
37. **01/10 18:58** — eu vou te manda os pints dps
38. **01/10 18:58** — já terminou o destroy?
39. **01/10 18:59** — já terminou o destroy?
40. **01/10 19:00** — já terminou o destroy?
41. **01/10 19:01** — pode fazer o 2 e o 3
42. **01/10 19:03** — eu quero subri e tira os print
43. **01/10 19:03** — já terminou o apply?
44. **01/10 19:03** — já terminou o apply?
45. **01/10 19:05** — já terminou o apply?
46. **01/10 19:05** — eu querio eu vc trira os print
47. **01/10 19:06** — me manda os comandos para treminal no vs code
48. **01/10 19:11** — [credenciais AWS coladas — omitidas por segurança]
49. **01/10 19:18** — [credenciais AWS coladas — omitidas por segurança]
50. **01/10 19:19** — me manda os comandos
51. **01/10 19:20** — [colou o erro do terminal: `api error AccessDenied ... StatusCode: 403` ao aplicar o backend S3]
52. **01/10 19:20** — roda o terraform
53. **01/10 19:26** — [Image #11] colocar na evidecias
54. **01/10 19:26** — [Image #12]
55. **01/10 19:32** — [credenciais AWS coladas — omitidas por segurança]
56. **01/10 19:33** — muda para subri pq aws deu ruim
57. **01/10 19:48** — tira os pints e so deixa os txt
58. **01/10 19:56** — [credenciais AWS coladas — omitidas por segurança]
59. **01/10 19:57** — [credenciais AWS coladas — omitidas por segurança]
60. **01/10 20:04** — já terminou o apply?
61. **01/10 20:06** — já terminou o apply?
62. **01/10 20:06** — já terminou o apply?
63. **01/10 20:09** — já terminou o apply?
64. **01/10 20:10** — já terminou o apply?
65. **01/10 20:11** — já terminou o apply?
66. **01/10 21:08** — já terminou o apply?
67. **01/10 21:10** — já terminou o apply?
68. **01/10 21:10** — já terminou o apply?
69. **01/10 21:14** — já terminou o apply?
70. **01/10 21:15** — já terminou o apply?
71. **01/10 21:17** — já terminou o apply?
72. **01/10 21:22** — gera as evidências dessa subida
73. **01/10 21:24** — pq o - http://3.86.96.150:3000/reservas (vazio, [], porque o banco é novo) cade o o banco
74. **01/10 21:24** — [credenciais AWS coladas — omitidas por segurança]
75. **01/10 21:25** — gera as evidências
76. **01/10 21:28** — pode fazer o terraform destroy
77. **01/10 21:28** — já terminou o destroy?
78. **01/10 21:29** — já terminou o destroy?
79. **01/10 21:30** — já terminou o destroy?
80. **01/10 21:34** — pega os resudatos e colocar em txt do novos e dps faz o pr mais nao coloca vc no pr
81. **01/10 21:36** — Agora reescrevo a parte da nuvem do entrega.md com os resultados da subida nova, com links para a pasta subida-conta-377871695195/. Leio o arquivo atual antes:
82. **01/10 21:41** — ja revivou as resposta no
83. **01/10 21:42** — pode escrever no relatorio
84. **01/10 21:45** — olha tudo de novo e ve se nao falta nada
85. **01/10 21:47** — A 2ª subida na conta [outra conta do Learner Lab] está sem destroy. pode destroy
86. **01/10 21:48** — [credenciais AWS coladas — omitidas por segurança]
87. **01/10 21:50** — │ [outra conta do Learner Lab] │ weslley_lucas_souza_alves │ Outro Lab seu (outra disciplina). Nada da prova lá esta nao [outra conta do Learner Lab] │ weslley_lucas_souza_alves │ ⚠️ 2ª subida sem destroy. As credenciais foram canceladas esta aqui nao nao so deixa 377871695195 │ Testar_aluno │ ✅ 3ª subida já destruída. São essas credenciais esta conta so ]
88. **01/10 21:53** — no relatrio so deixa esta conta e ve se aprecer as outras na evidecas
