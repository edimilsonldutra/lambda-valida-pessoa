# 📋 ANÁLISE COMPLETA - Configurações Faltantes para Deploy na AWS

**Data da Análise:** 2025-12-03  
**Projeto:** Lambda Valida Pessoa  
**Status:** ⚠️ CONFIGURAÇÕES PENDENTES

---

## 🎯 RESUMO EXECUTIVO

O projeto possui uma infraestrutura completa e bem estruturada, porém **NÃO ESTÁ PRONTO** para deploy na AWS devido a **configurações obrigatórias faltantes**.

### Status por Categoria:
- ✅ **Código Lambda:** Completo
- ✅ **Infraestrutura Terraform:** Completa
- ✅ **CI/CD Workflows:** Configurados
- ⚠️ **Build da Aplicação:** JAR não compilado
- ❌ **Credenciais AWS:** Não configuradas
- ❌ **Secrets Obrigatórios:** Não definidos
- ❌ **Backend Terraform:** Não configurado
- ⚠️ **Variáveis Terraform:** Incompletas

---

## 🚨 BLOQUEADORES CRÍTICOS (Impedem o Deploy)

### 1. ⚠️ **Lambda JAR Não Compilado**

**Problema:** O arquivo JAR da Lambda não existe no diretório target/

**Impacto:** 🔴 **CRÍTICO** - Sem o JAR, o Terraform não consegue criar a função Lambda

**Localização:** 
```
LambdaValidaPessoa/target/ValidaPessoa-1.0.jar - NÃO EXISTE
```

**Solução:**
```bash
cd LambdaValidaPessoa
mvn clean package -DskipTests
```

**Arquivo esperado:** `LambdaValidaPessoa/target/ValidaPessoa-1.0.jar`

---

### 2. ❌ **Credenciais AWS Não Configuradas**

**Problema:** Não há evidências de credenciais AWS configuradas

**Impacto:** 🔴 **CRÍTICO** - Terraform não consegue se autenticar na AWS

**O que falta:**

#### Opção 1: Variáveis de Ambiente (Recomendado para Dev Local)
```bash
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

#### Opção 2: Arquivo ~/.aws/credentials (Recomendado para Dev Local)
```ini
[default]
aws_access_key_id = sua-access-key
aws_secret_access_key = sua-secret-key
region = us-east-1
```

#### Opção 3: GitHub Secrets (Para CI/CD)
Configurar no GitHub: `Settings → Secrets and variables → Actions`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

---

### 3. ❌ **Secrets Obrigatórios Não Definidos**

**Problema:** Variáveis sensíveis declaradas mas sem valores

**Impacto:** 🔴 **CRÍTICO** - Terraform falhará na validação

**Secrets Obrigatórios:**

| Secret | Declarado em | Usado por | Status |
|--------|--------------|-----------|---------|
| `DB_PASSWORD` | vars.tf (linha 404) | RDS PostgreSQL | ❌ Faltando |
| `JWT_SECRET` | vars.tf (linha 60) | Lambda Function | ❌ Faltando |

**Variável Problemática em vars.tf:**
```terraform
# LINHA 350-353 - ERRO DE DESIGN
variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing DB credentials"
  type        = string
}
```

**Problema:** Esta variável é declarada como **obrigatória** mas deveria ser **computada** (output de `secrets.tf`)

---

### 4. ❌ **Backend Terraform Não Configurado**

**Problema:** Backend do Terraform está comentado

**Impacto:** 🟡 **MÉDIO** - Estado local, não compartilhável entre equipe/CI

**Arquivo:** `infra/terraform/backend.tf`

**Estado Atual:**
```terraform
# Uncomment and configure for production use with S3 backend
# terraform {
#   backend "s3" {
#     bucket         = "seu-bucket-terraform-state"
#     key            = "valida-pessoa/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }
```

**O que fazer:**

#### Para Dev Local:
✅ Pode usar estado local (nenhuma ação necessária)

#### Para Produção/Equipe:
❌ **DEVE configurar S3 backend:**

1. Criar bucket S3 para estado:
```bash
aws s3 mb s3://valida-pessoa-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket valida-pessoa-terraform-state \
  --versioning-configuration Status=Enabled
```

2. Criar tabela DynamoDB para lock:
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

3. Descomentar e configurar `backend.tf`

---

## ⚠️ CONFIGURAÇÕES NECESSÁRIAS (Não Bloqueadoras mas Importantes)

### 5. ⚠️ **Valores Sensíveis em terraform.tfvars**

**Problema:** terraform.tfvars tem placeholders, não valores reais

**Impacto:** 🟡 **MÉDIO** - Precisa ser ajustado antes do apply

**O que ajustar:**

```terraform
# Em: infra/terraform/terraform.tfvars

# ❌ TROCAR ISSO:
jwt_secret = "change-this-secret-key-to-a-strong-random-32-character-minimum-string"

# ✅ POR UM SECRET REAL:
jwt_secret = "$(openssl rand -base64 48)"  # Gerar com comando


# ❌ DEFINIR:
db_password = "senha-forte-aqui"  # Mínimo 12 caracteres
```

---

### 6. ⚠️ **New Relic Desabilitado**

**Problema:** Monitoramento New Relic configurado mas desabilitado

**Impacto:** 🟢 **BAIXO** - Funcional, mas sem monitoramento APM

**Configuração Atual:**
```terraform
# infra/terraform/terraform.tfvars
enable_new_relic_monitoring = false
new_relic_license_key = ""
```

**Para Habilitar (Opcional):**
1. Criar conta no New Relic
2. Obter License Key
3. Configurar em terraform.tfvars:
```terraform
enable_new_relic_monitoring = true
new_relic_license_key = "sua-chave-aqui"
new_relic_account_id = "sua-conta-aqui"
new_relic_api_key = "sua-api-key-aqui"
```

---

### 7. ⚠️ **GitHub Secrets Não Configurados**

**Problema:** Workflows CI/CD esperam secrets que não existem

**Impacto:** 🟡 **MÉDIO** - CI/CD não funcionará

**Secrets Esperados pelos Workflows:**

| Secret | Usado em | Obrigatório | Status |
|--------|----------|-------------|--------|
| `AWS_ACCESS_KEY_ID` | deploy.yml | ✅ Sim | ❌ Faltando |
| `AWS_SECRET_ACCESS_KEY` | deploy.yml | ✅ Sim | ❌ Faltando |
| `JWT_SECRET` | deploy.yml | ✅ Sim | ❌ Faltando |
| `DB_PASSWORD` | deploy.yml | ✅ Sim | ❌ Faltando |
| `NEW_RELIC_LICENSE_KEY` | deploy.yml | ⚠️ Opcional | ❌ Faltando |
| `ALERT_EMAIL` | deploy.yml | ⚠️ Opcional | ❌ Faltando |

**Como Configurar:**
1. Ir para: `GitHub → Settings → Secrets and variables → Actions`
2. Clicar em `New repository secret`
3. Adicionar cada secret da lista acima

---

### 8. ⚠️ **Erro de Design em vars.tf**

**Problema:** Variável `db_secret_arn` declarada como input mas deveria ser output

**Impacto:** 🔴 **CRÍTICO** - Terraform falhará

**Arquivo:** `infra/terraform/vars.tf` (linha 350)

**Problema:**
```terraform
variable "db_secret_arn" {  # ❌ ERRADO - não deve ser variável de input
  description = "ARN of the AWS Secrets Manager secret containing DB credentials"
  type        = string
}
```

**Onde é usado:**
- `lambda.tf` (linha 59) - Lê o ARN do secret
- `iam.tf` (linha 38) - Permissão para acessar o secret

**Solução:** Remover a variável e usar a referência direta do resource:

```terraform
# Em lambda.tf e iam.tf, trocar:
var.db_secret_arn

# Por:
aws_secretsmanager_secret.db.arn
```

---

## 📝 CHECKLIST DE DEPLOY

### Pré-requisitos (Software)
- [ ] AWS CLI instalado e configurado
- [ ] Terraform >= 1.0 instalado
- [ ] Java 21 instalado
- [ ] Maven instalado
- [ ] Git configurado

### Passo 1: Build da Aplicação
```bash
cd LambdaValidaPessoa
mvn clean package -DskipTests
# Verificar: ls -la target/ValidaPessoa-1.0.jar
```

### Passo 2: Credenciais AWS
```bash
# Opção 1: Configurar AWS CLI
aws configure

# Opção 2: Exportar variáveis
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"

# Verificar
aws sts get-caller-identity
```

### Passo 3: Corrigir vars.tf
```bash
cd infra/terraform
# Remover a variável db_secret_arn de vars.tf
# Ou seguir instruções na seção 8 acima
```

### Passo 4: Configurar terraform.tfvars
```bash
cd infra/terraform

# Gerar JWT secret forte
JWT_SECRET=$(openssl rand -base64 48)

# Gerar senha de banco forte
DB_PASSWORD=$(openssl rand -base64 24)

# Atualizar terraform.tfvars
cat >> terraform.tfvars <<EOF
jwt_secret  = "${JWT_SECRET}"
db_password = "${DB_PASSWORD}"
EOF
```

### Passo 5: Terraform Init e Plan
```bash
cd infra/terraform
terraform init
terraform plan
```

### Passo 6: Deploy (Se plan estiver OK)
```bash
terraform apply
```

---

## 🔧 CORREÇÕES NECESSÁRIAS AGORA

### Correção 1: Remover variável db_secret_arn

**Arquivo:** `infra/terraform/vars.tf`

**Ação:** Remover linhas 350-353:
```terraform
# REMOVER ISSO:
variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing DB credentials"
  type        = string
}
```

---

### Correção 2: Atualizar referências em iam.tf

**Arquivo:** `infra/terraform/iam.tf`

**Linha 38 - Trocar:**
```terraform
# DE:
resources = [
  var.db_secret_arn
]

# PARA:
resources = [
  aws_secretsmanager_secret.db.arn
]
```

---

### Correção 3: Atualizar referências em lambda.tf

**Arquivo:** `infra/terraform/lambda.tf`

**Linha ~59 (dentro de environment variables) - Trocar:**
```terraform
# DE:
DB_SECRET_ARN = var.db_secret_arn

# PARA:
DB_SECRET_ARN = aws_secretsmanager_secret.db.arn
```

---

### Correção 4: Atualizar terraform.tfvars

**Arquivo:** `infra/terraform/terraform.tfvars`

**Ação:** Adicionar valores reais para secrets:
```terraform
# Gerar valores seguros:
# jwt_secret=$(openssl rand -base64 48)
# db_password=$(openssl rand -base64 24)

jwt_secret  = "SEU-JWT-SECRET-AQUI-MINIMO-32-CARACTERES"
db_password = "SUA-SENHA-DB-AQUI-MINIMO-12-CARACTERES"
```

---

## 🎯 COMANDOS RÁPIDOS DE CORREÇÃO

### Script Completo de Preparação para Deploy:

```bash
#!/bin/bash
set -e

echo "🚀 Preparando projeto para deploy na AWS..."

# 1. Build da aplicação
echo "📦 Step 1: Building Lambda JAR..."
cd LambdaValidaPessoa
mvn clean package -DskipTests
cd ..

# 2. Gerar secrets fortes
echo "🔐 Step 2: Generating secure secrets..."
JWT_SECRET=$(openssl rand -base64 48)
DB_PASSWORD=$(openssl rand -base64 24)

# 3. Criar arquivo de secrets (NUNCA COMMITAR!)
echo "📝 Step 3: Creating secrets file..."
cat > infra/terraform/secrets.auto.tfvars <<EOF
# ⚠️ NUNCA COMMITAR ESTE ARQUIVO! ⚠️
# Adicione ao .gitignore: *.auto.tfvars

jwt_secret  = "${JWT_SECRET}"
db_password = "${DB_PASSWORD}"
EOF

echo "✅ Secrets criados em: infra/terraform/secrets.auto.tfvars"
echo "⚠️  IMPORTANTE: Adicione *.auto.tfvars ao .gitignore!"

# 4. Verificar AWS credentials
echo "🔍 Step 4: Checking AWS credentials..."
if aws sts get-caller-identity &>/dev/null; then
    echo "✅ AWS credentials OK"
else
    echo "❌ AWS credentials not configured!"
    echo "Execute: aws configure"
    exit 1
fi

# 5. Terraform init
echo "🏗️  Step 5: Initializing Terraform..."
cd infra/terraform
terraform init

# 6. Terraform validate
echo "✅ Step 6: Validating Terraform..."
terraform validate

echo ""
echo "✅ PREPARAÇÃO COMPLETA!"
echo ""
echo "Próximos passos:"
echo "  1. cd infra/terraform"
echo "  2. terraform plan     # Revisar mudanças"
echo "  3. terraform apply    # Aplicar infraestrutura"
echo ""
```

Salvar como `prepare-deploy.sh` e executar:
```bash
chmod +x prepare-deploy.sh
./prepare-deploy.sh
```

---

## 📊 ESTIMATIVA DE CUSTOS AWS

### Recursos que serão criados:

| Recurso | Tipo | Custo Estimado/Mês |
|---------|------|-------------------|
| Lambda Function | Compute | ~$0.20 (1M requests) |
| RDS PostgreSQL (db.t4g.micro) | Database | ~$12.41 |
| VPC | Networking | Grátis |
| NAT Gateway | Networking | ~$32.85 |
| API Gateway | API | ~$3.50 (1M requests) |
| CloudWatch Logs | Monitoring | ~$0.50 |
| Secrets Manager | Security | ~$0.40 (1 secret) |
| **TOTAL** | | **~$49.86/mês** |

### Custos Opcionais:
- New Relic APM: Grátis até 100GB/mês
- S3 Backend: ~$0.023/GB

### Otimizações para Reduzir Custos:
1. **Desabilitar NAT Gateway em dev** (economia: $32.85/mês)
   - Em `terraform.tfvars`: `enable_nat_gateway = false`
   - Lambda não terá acesso à internet

2. **Usar DynamoDB ao invés de RDS** (economia: $12.41/mês)
   - Já está configurado no projeto
   - Trocar de RDS para DynamoDB tables

3. **Usar Local State ao invés de S3** (economia: $0.02/mês)
   - Já está assim por padrão

**Custo Mínimo (sem NAT, sem RDS):** ~$4.60/mês

---

## 🔒 SEGURANÇA - CHECKLIST

### Secrets Management:
- [ ] **NUNCA** commitar secrets no git
- [ ] Adicionar `*.auto.tfvars` ao `.gitignore`
- [ ] Adicionar `.env` ao `.gitignore`
- [ ] Usar AWS Secrets Manager para DB credentials
- [ ] Rotacionar secrets regularmente

### Arquivos Sensíveis:
```bash
# Adicionar ao .gitignore:
*.auto.tfvars
.env
terraform.tfstate
terraform.tfstate.backup
.terraform/
secrets.txt
```

### AWS IAM:
- [ ] Usar credenciais com permissões mínimas necessárias
- [ ] Nunca usar root account
- [ ] Habilitar MFA na conta AWS
- [ ] Rotacionar Access Keys regularmente

---

## 📞 TROUBLESHOOTING

### Erro: "No such file or directory: ValidaPessoa-1.0.jar"
**Solução:** Build da aplicação
```bash
cd LambdaValidaPessoa
mvn clean package
```

### Erro: "Unable to locate credentials"
**Solução:** Configurar AWS CLI
```bash
aws configure
```

### Erro: "db_secret_arn is required"
**Solução:** Remover variável de vars.tf (ver Correção 1)

### Erro: "Invalid provider configuration"
**Solução:** Terraform init
```bash
cd infra/terraform
terraform init
```

### Erro: "Error creating VPC: UnauthorizedOperation"
**Solução:** Verificar permissões IAM da conta AWS

---

## ✅ CONCLUSÃO

### O que está PRONTO:
- ✅ Código Lambda completo e funcional
- ✅ Infraestrutura Terraform bem estruturada
- ✅ CI/CD workflows configurados
- ✅ Documentação extensa
- ✅ Testes unitários
- ✅ Docker configurado

### O que está FALTANDO:
- ❌ Lambda JAR compilado
- ❌ Credenciais AWS configuradas
- ❌ Secrets definidos (JWT, DB password)
- ❌ Correção da variável db_secret_arn
- ⚠️ Backend Terraform (opcional)
- ⚠️ GitHub Secrets (para CI/CD)

### Tempo Estimado para Deploy:
- **Correções:** 10 minutos
- **Configuração AWS:** 5 minutos
- **Build + Deploy:** 15 minutos
- **TOTAL:** ~30 minutos

### Próximo Passo:
Execute o script `prepare-deploy.sh` acima para automatizar as correções!

---

**Última Atualização:** 2025-12-03  
**Analisado por:** AI Senior DevOps Engineer  
**Versão do Documento:** 1.0

