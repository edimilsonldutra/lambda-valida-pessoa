# 🚀 RESUMO RÁPIDO - Configurações Faltantes para Deploy AWS

**Última Atualização:** 2025-12-03  
**Status:** ⚠️ BLOQUEADORES IDENTIFICADOS

---

## ⚡ RESUMO EXECUTIVO (TL;DR)

O projeto **NÃO está pronto** para deploy. Faltam **4 configurações críticas**:

1. ❌ **Lambda JAR não compilado** → Executar: `mvn clean package`
2. ❌ **Credenciais AWS não configuradas** → Executar: `aws configure`
3. ❌ **Secrets não definidos** (JWT, DB password) → Gerar valores seguros
4. ❌ **Erro em vars.tf** (variável db_secret_arn) → Remover variável

**Solução Rápida:** Execute o script automático:
```bash
# Linux/Mac
chmod +x prepare-deploy.sh
./prepare-deploy.sh

# Windows
prepare-deploy.bat
```

---

## 🔴 BLOQUEADORES CRÍTICOS

| # | Problema | Impacto | Solução Rápida |
|---|----------|---------|----------------|
| 1 | JAR não existe | 🔴 Deploy impossível | `cd LambdaValidaPessoa && mvn clean package` |
| 2 | AWS creds ausentes | 🔴 Terraform não autentica | `aws configure` |
| 3 | Secrets vazios | 🔴 Validação Terraform falha | Gerar com `openssl rand -base64 48` |
| 4 | vars.tf incorreto | 🔴 Terraform plan falha | Remover `variable "db_secret_arn"` |

---

## ✅ SOLUÇÃO AUTOMATIZADA

### Opção 1: Script Automático (RECOMENDADO)

**Linux/Mac:**
```bash
chmod +x prepare-deploy.sh
./prepare-deploy.sh
```

**Windows:**
```cmd
prepare-deploy.bat
```

**O que o script faz:**
- ✅ Compila o Lambda JAR
- ✅ Gera secrets seguros automaticamente
- ✅ Cria arquivo `secrets.auto.tfvars`
- ✅ Atualiza `.gitignore`
- ✅ Verifica credenciais AWS
- ✅ Inicializa e valida Terraform

**Tempo:** ~5 minutos

---

### Opção 2: Manual (Passo a Passo)

#### 1. Compilar Lambda JAR
```bash
cd LambdaValidaPessoa
mvn clean package -DskipTests
# Verifica: ls -la target/ValidaPessoa-1.0.jar
cd ..
```

#### 2. Configurar AWS Credentials
```bash
# Opção A: AWS CLI
aws configure

# Opção B: Variáveis de ambiente
export AWS_ACCESS_KEY_ID="sua-key"
export AWS_SECRET_ACCESS_KEY="seu-secret"
export AWS_DEFAULT_REGION="us-east-1"

# Verificar
aws sts get-caller-identity
```

#### 3. Gerar e Configurar Secrets
```bash
# Gerar secrets
JWT_SECRET=$(openssl rand -base64 48)
DB_PASSWORD=$(openssl rand -base64 24)

# Criar arquivo de secrets
cat > infra/terraform/secrets.auto.tfvars <<EOF
jwt_secret  = "${JWT_SECRET}"
db_password = "${DB_PASSWORD}"
EOF

# IMPORTANTE: Adicionar ao .gitignore
echo "*.auto.tfvars" >> .gitignore
```

#### 4. Corrigir vars.tf

**Remover estas linhas de `infra/terraform/vars.tf` (linhas 350-353):**
```terraform
variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing DB credentials"
  type        = string
}
```

**Atualizar `infra/terraform/iam.tf` (linha 38):**
```terraform
# DE:
resources = [ var.db_secret_arn ]

# PARA:
resources = [ aws_secretsmanager_secret.db.arn ]
```

**Atualizar `infra/terraform/lambda.tf` (linha ~59):**
```terraform
# DE:
DB_SECRET_ARN = var.db_secret_arn

# PARA:
DB_SECRET_ARN = aws_secretsmanager_secret.db.arn
```

#### 5. Terraform Init e Validate
```bash
cd infra/terraform
terraform init
terraform validate
```

---

## 📝 CHECKLIST VISUAL

```
┌─────────────────────────────────────────────────────┐
│ PRÉ-REQUISITOS (Software)                          │
├─────────────────────────────────────────────────────┤
│ [ ] Java 21 instalado                              │
│ [ ] Maven instalado                                │
│ [ ] AWS CLI instalado                              │
│ [ ] Terraform >= 1.0 instalado                     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ CONFIGURAÇÕES OBRIGATÓRIAS                         │
├─────────────────────────────────────────────────────┤
│ [ ] Lambda JAR compilado                           │
│ [ ] Credenciais AWS configuradas                   │
│ [ ] JWT_SECRET definido (min 32 chars)             │
│ [ ] DB_PASSWORD definido (min 12 chars)            │
│ [ ] vars.tf corrigido (sem db_secret_arn)          │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ CONFIGURAÇÕES OPCIONAIS (mas recomendadas)         │
├─────────────────────────────────────────────────────┤
│ [ ] Backend S3 configurado (para produção)         │
│ [ ] GitHub Secrets configurados (para CI/CD)       │
│ [ ] New Relic habilitado (para monitoramento)      │
│ [ ] *.auto.tfvars no .gitignore                    │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 APÓS CORREÇÕES

### Deploy na AWS:
```bash
cd infra/terraform

# 1. Revisar o plano
terraform plan

# 2. Aplicar (se plan OK)
terraform apply

# 3. Obter URL da API
terraform output api_gateway_url
```

### Testar API:
```bash
# Obter URL do output
API_URL=$(terraform output -raw api_gateway_url)

# Testar endpoint
curl -X POST "${API_URL}" \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}'
```

---

## 💰 CUSTOS ESTIMADOS

| Recurso | Custo/Mês |
|---------|-----------|
| Lambda | $0.20 |
| RDS (db.t4g.micro) | $12.41 |
| NAT Gateway | $32.85 |
| API Gateway | $3.50 |
| Outros | $1.00 |
| **TOTAL** | **~$49.86** |

### Otimizações para DEV:
```terraform
# Em terraform.tfvars, adicione:
enable_nat_gateway = false  # Economiza $32.85/mês
db_multi_az = false        # Já está false
```

**Custo mínimo DEV:** ~$17/mês (sem NAT Gateway)

---

## 🔒 SEGURANÇA - IMPORTANTE!

### ⚠️ NUNCA COMMITAR:
- ❌ `secrets.auto.tfvars`
- ❌ `.secrets-backup.txt`
- ❌ `terraform.tfstate`
- ❌ Arquivos `.env` com secrets

### ✅ SEMPRE FAZER:
- ✅ Adicionar `*.auto.tfvars` ao `.gitignore`
- ✅ Usar senhas fortes (min 32 chars)
- ✅ Rotacionar secrets regularmente
- ✅ Usar AWS Secrets Manager
- ✅ Habilitar MFA na conta AWS

---

## 📚 DOCUMENTAÇÃO COMPLETA

Para análise detalhada, consulte:
- 📖 **ANALISE_CONFIGURACAO_DEPLOY_AWS.md** - Análise completa (15 páginas)
- 📋 **Este arquivo** - Resumo rápido
- 🔧 **prepare-deploy.sh/.bat** - Scripts de automação

---

## ❓ TROUBLESHOOTING RÁPIDO

| Erro | Causa | Solução |
|------|-------|---------|
| "No such file: ValidaPessoa-1.0.jar" | JAR não compilado | `mvn clean package` |
| "Unable to locate credentials" | AWS não configurado | `aws configure` |
| "db_secret_arn is required" | Variável incorreta | Remover de vars.tf |
| "Access Denied" | Permissões IAM | Verificar IAM user |
| "Invalid provider" | Terraform não init | `terraform init` |

---

## ✅ STATUS ATUAL DO PROJETO

### ✅ O QUE ESTÁ BOM:
- ✅ Código Lambda completo e funcional
- ✅ Infraestrutura Terraform bem estruturada
- ✅ CI/CD workflows configurados
- ✅ Testes unitários implementados
- ✅ Documentação extensa
- ✅ Docker configurado
- ✅ Segurança implementada (VPC, SG, Secrets Manager)

### ❌ O QUE FALTA:
- ❌ **4 configurações críticas** (listadas acima)
- ⚠️ GitHub Secrets (para CI/CD)
- ⚠️ Backend S3 (para produção)

### ⏱️ TEMPO ESTIMADO:
- **Com script automático:** 5-10 minutos
- **Manual:** 15-20 minutos
- **Deploy na AWS:** 15-20 minutos
- **TOTAL:** ~30-40 minutos até API funcionando

---

## 🚀 COMANDOS FINAIS

```bash
# 1. Preparar ambiente (ESCOLHA UM):
./prepare-deploy.sh          # Linux/Mac
prepare-deploy.bat           # Windows

# 2. Deploy
cd infra/terraform
terraform plan
terraform apply

# 3. Testar
curl -X POST "$(terraform output -raw api_gateway_url)" \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}'

# 4. Cleanup (quando não precisar mais)
terraform destroy
```

---

## 📞 SUPORTE

Se encontrar problemas:
1. Consulte **ANALISE_CONFIGURACAO_DEPLOY_AWS.md** seção "Troubleshooting"
2. Verifique logs do Terraform: `terraform apply -debug`
3. Verifique logs AWS CloudWatch após deploy

---

**Próximo Passo:** Execute `prepare-deploy.sh` ou `prepare-deploy.bat` AGORA!

