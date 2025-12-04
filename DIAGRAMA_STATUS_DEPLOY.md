# 📊 DIAGRAMA - Status do Deploy AWS

```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                    PROJETO: Lambda Valida Pessoa                         ║
║                    STATUS DEPLOY AWS: ⚠️ NÃO PRONTO                     ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝


┌──────────────────────────────────────────────────────────────────────────┐
│                         ANÁLISE DE COMPONENTES                            │
└──────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│   CÓDIGO LAMBDA     │
│   ✅ COMPLETO       │
├─────────────────────┤
│ • Java 21           │
│ • Handler OK        │
│ • Dependencies OK   │
│ • Tests OK          │
└─────────────────────┘
         │
         │ ❌ JAR NÃO COMPILADO
         ↓
┌─────────────────────┐
│   BUILD MAVEN       │
│   ❌ FALTANDO       │
├─────────────────────┤
│ • mvn package       │
│   não executado     │
│ • target/ vazio     │
└─────────────────────┘


┌─────────────────────┐
│   TERRAFORM IaC     │
│   ✅ COMPLETO       │
├─────────────────────┤
│ • VPC config ✅     │
│ • RDS config ✅     │
│ • Lambda config ✅  │
│ • API GW config ✅  │
│ • IAM roles ✅      │
└─────────────────────┘
         │
         │ ❌ VARIÁVEIS INCOMPLETAS
         ↓
┌─────────────────────┐
│   VARS.TF           │
│   ⚠️ COM ERRO       │
├─────────────────────┤
│ • db_secret_arn     │
│   deveria ser       │
│   computed, não     │
│   input var         │
└─────────────────────┘


┌─────────────────────┐
│   SECRETS           │
│   ❌ VAZIOS         │
├─────────────────────┤
│ JWT_SECRET: ""      │
│ DB_PASSWORD: ""     │
│                     │
│ Status: Placeholders│
└─────────────────────┘


┌─────────────────────┐
│   AWS CREDENTIALS   │
│   ❌ NÃO CONFIG     │
├─────────────────────┤
│ • AWS_ACCESS_KEY    │
│   não definida      │
│ • AWS_SECRET_KEY    │
│   não definida      │
└─────────────────────┘


┌─────────────────────┐
│   CI/CD WORKFLOWS   │
│   ✅ CONFIGURADOS   │
├─────────────────────┤
│ • deploy.yml ✅     │
│ • ci.yml ✅         │
│ • cd-*.yml ✅       │
└─────────────────────┘
         │
         │ ⚠️ GITHUB SECRETS FALTANDO
         ↓
┌─────────────────────┐
│   GITHUB SECRETS    │
│   ❌ VAZIOS         │
├─────────────────────┤
│ • AWS_ACCESS_KEY    │
│ • AWS_SECRET_KEY    │
│ • JWT_SECRET        │
│ • DB_PASSWORD       │
│ Status: Não config  │
└─────────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                         BLOQUEADORES CRÍTICOS                            │
└─────────────────────────────────────────────────────────────────────────┘

    🔴 BLOQUEADOR 1: Lambda JAR não compilado
    ├─ Arquivo esperado: LambdaValidaPessoa/target/ValidaPessoa-1.0.jar
    ├─ Status atual: ❌ Não existe
    └─ Solução: mvn clean package

    🔴 BLOQUEADOR 2: Credenciais AWS ausentes
    ├─ AWS_ACCESS_KEY_ID: ❌ Não definida
    ├─ AWS_SECRET_ACCESS_KEY: ❌ Não definida
    └─ Solução: aws configure

    🔴 BLOQUEADOR 3: Secrets vazios
    ├─ JWT_SECRET: ❌ Placeholder
    ├─ DB_PASSWORD: ❌ Placeholder
    └─ Solução: Gerar valores seguros

    🔴 BLOQUEADOR 4: Erro em vars.tf
    ├─ variable "db_secret_arn": ❌ Não deveria existir
    ├─ Causa referência circular
    └─ Solução: Remover variável e usar aws_secretsmanager_secret.db.arn


┌─────────────────────────────────────────────────────────────────────────┐
│                      FLUXO DE DEPLOY (IDEAL)                             │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│              │       │              │       │              │
│  Código Java │──────▶│  Maven Build │──────▶│   JAR File   │
│              │       │              │       │              │
└──────────────┘       └──────────────┘       └──────────────┘
                                                      │
                                                      │
                                                      ▼
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│              │       │              │       │              │
│ AWS Account  │◀──────│  Terraform   │◀──────│ Config Files │
│              │       │  (apply)     │       │  (.tfvars)   │
└──────────────┘       └──────────────┘       └──────────────┘
      │                                               │
      │                                               │
      │ Cria recursos:                                │ Precisa:
      │ • VPC                                         │ • jwt_secret
      │ • RDS                                         │ • db_password
      │ • Lambda                                      │ • AWS creds
      │ • API Gateway                                 │
      │                                               │
      ▼                                               ▼
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│                    API FUNCIONANDO                           │
│         https://xxxxx.execute-api.us-east-1.amazonaws.com    │
│                                                              │
└──────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                      ESTADO ATUAL vs NECESSÁRIO                          │
└─────────────────────────────────────────────────────────────────────────┘

Componente              │ Estado Atual │ Necessário │ Gap
─────────────────────────┼──────────────┼────────────┼─────────────────
Código Lambda           │      ✅      │     ✅     │ OK
Lambda JAR              │      ❌      │     ✅     │ 🔴 CRÍTICO
Terraform configs       │      ✅      │     ✅     │ OK
vars.tf                 │      ⚠️      │     ✅     │ 🔴 ERRO
terraform.tfvars        │      ⚠️      │     ✅     │ ⚠️ INCOMPLETO
AWS Credentials         │      ❌      │     ✅     │ 🔴 CRÍTICO
Secrets (JWT, DB)       │      ❌      │     ✅     │ 🔴 CRÍTICO
Backend S3              │      ⚠️      │     ⚠️     │ 🟡 OPCIONAL
GitHub Secrets          │      ❌      │     ⚠️     │ 🟡 PARA CI/CD
New Relic               │      ⚠️      │     ⚠️     │ 🟡 OPCIONAL


┌─────────────────────────────────────────────────────────────────────────┐
│                         SOLUÇÃO AUTOMÁTICA                               │
└─────────────────────────────────────────────────────────────────────────┘

        Execute um dos scripts de preparação:

        ┌──────────────────────────────────────────────┐
        │                                              │
        │   Linux/Mac:                                 │
        │   $ chmod +x prepare-deploy.sh               │
        │   $ ./prepare-deploy.sh                      │
        │                                              │
        │   Windows:                                   │
        │   > prepare-deploy.bat                       │
        │                                              │
        └──────────────────────────────────────────────┘

        O script irá:
        ✅ 1. Compilar Lambda JAR
        ✅ 2. Gerar secrets seguros
        ✅ 3. Criar secrets.auto.tfvars
        ✅ 4. Verificar AWS credentials
        ✅ 5. Inicializar Terraform
        ✅ 6. Validar configuração

        Tempo estimado: 5-10 minutos


┌─────────────────────────────────────────────────────────────────────────┐
│                      ARQUITETURA PÓS-DEPLOY                              │
└─────────────────────────────────────────────────────────────────────────┘

                        ┌─────────────────┐
                        │   Internet      │
                        │   (Users)       │
                        └────────┬────────┘
                                 │
                                 │ HTTPS
                                 ▼
                        ┌─────────────────┐
                        │  API Gateway    │◀─── Logs CloudWatch
                        │  (REST API)     │
                        └────────┬────────┘
                                 │
                                 │ Invoke
                                 ▼
    ┌─────────────────────────────────────────────────────┐
    │              VPC (10.0.0.0/16)                      │
    │                                                      │
    │  ┌─────────────┐        ┌──────────────┐           │
    │  │ Public      │        │ Private      │            │
    │  │ Subnet      │        │ Subnet       │            │
    │  │             │        │              │            │
    │  │ ┌─────────┐ │        │ ┌──────────┐ │           │
    │  │ │   NAT   │ │        │ │  Lambda  │◀┼──── Logs │
    │  │ │ Gateway │ │        │ │ Function │ │           │
    │  │ └─────────┘ │        │ └────┬─────┘ │           │
    │  │             │        │      │       │            │
    │  └─────────────┘        │      │       │            │
    │                         │      ▼       │            │
    │                         │ ┌──────────┐ │            │
    │                         │ │   RDS    │ │            │
    │                         │ │ Postgres │ │            │
    │                         │ └──────────┘ │            │
    │                         │              │            │
    │                         └──────────────┘            │
    │                                                      │
    └──────────────────────────────────────────────────────┘
                        │
                        │ Acesso
                        ▼
              ┌──────────────────┐
              │ Secrets Manager  │
              │ (DB Credentials) │
              └──────────────────┘


┌───────────────────────────────────���─────────────────────────────────────┐
│                      CUSTOS MENSAIS ESTIMADOS                            │
└─────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────┬──────────────┬─────────────────┐
    │      Recurso           │   Custo/Mês  │  Otimização     │
    ├────────────────────────┼──────────────┼─────────────────┤
    │ Lambda (1M requests)   │    $0.20     │  ✅ Já otimizado│
    │ RDS db.t4g.micro       │   $12.41     │  ⚠️ Usar DynamoDB│
    │ NAT Gateway            │   $32.85     │  ⚠️ Desabilitar │
    │ API Gateway (1M req)   │    $3.50     │  ✅ Já otimizado│
    │ CloudWatch Logs        │    $0.50     │  ✅ OK          │
    │ Secrets Manager        │    $0.40     │  ✅ OK          │
    ├────────────────────────┼──────────────┼─────────────────┤
    │ TOTAL PRODUÇÃO         │   $49.86     │                 │
    │ TOTAL DEV (otimizado)  │   $17.01     │  Sem NAT/RDS    │
    └────────────────────────┴──────────────┴─────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                         TIMELINE DE DEPLOY                               │
└─────────────────────────────────────────────────────────────────────────┘

    T=0min    Execute prepare-deploy script
    │
    T=5min    ✅ Preparação completa
    │         • JAR compilado
    │         • Secrets gerados
    │         • Terraform validado
    │
    T=10min   Execute: terraform plan
    │
    T=15min   Execute: terraform apply
    │         Criando recursos AWS...
    │         ├─ VPC (1 min)
    │         ├─ RDS (5 min)
    │         ├─ Lambda (2 min)
    │         └─ API Gateway (1 min)
    │
    T=25min   ✅ Deploy completo
    │         API URL disponível
    │
    T=30min   Teste da API
              ✅ Sistema funcionando!


┌─────────────────────────────────────────────────────────────────────────┐
│                      PRÓXIMOS PASSOS (SEQUENCIAL)                        │
└─────────────────────────────────────────────────────────────────────────┘

    [ ] 1. Execute o script de preparação
           ./prepare-deploy.sh (ou .bat no Windows)

    [ ] 2. Revise as configurações geradas
           cat infra/terraform/secrets.auto.tfvars

    [ ] 3. Execute Terraform plan
           cd infra/terraform && terraform plan

    [ ] 4. Aplique a infraestrutura
           terraform apply

    [ ] 5. Teste a API
           curl -X POST "$(terraform output -raw api_gateway_url)" \
             -H "Content-Type: application/json" \
             -d '{"cpf":"11144477735"}'

    [ ] 6. (Opcional) Configure GitHub Secrets para CI/CD

    [ ] 7. (Opcional) Habilite New Relic para monitoramento


╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                         ⚠️ ATENÇÃO SEGURANÇA ⚠️                         ║
║                                                                          ║
║  NUNCA commitar no Git:                                                 ║
║  • secrets.auto.tfvars                                                  ║
║  • .secrets-backup.txt                                                  ║
║  • terraform.tfstate                                                    ║
║  • Qualquer arquivo com credenciais                                     ║
║                                                                          ║
║  SEMPRE verificar .gitignore antes de commit!                           ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
```

