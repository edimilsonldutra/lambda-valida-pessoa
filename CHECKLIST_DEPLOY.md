# ✅ Checklist Completo - Deploy AWS Lambda Valida Pessoa

## 🎯 Configurações Faltantes Identificadas

---

## ❌ CRÍTICAS (Impedem o Deploy)

### ☐ 1. AWS CLI Não Instalada/Configurada
**Status:** ❌ FALTANDO  
**Prioridade:** 🔴 CRÍTICA  
**Tempo:** 10 minutos  

**Instalar:**
```bash
choco install awscli
# OU: https://awscli.amazonaws.com/AWSCLIV2.msi
```

**Configurar:**
```bash
aws configure
# Fornecer: Access Key ID, Secret Access Key, região
```

**Verificar:**
```bash
aws sts get-caller-identity
```

---

### ☐ 2. JAR da Lambda Não Compilado
**Status:** ❌ FALTANDO  
**Prioridade:** 🔴 CRÍTICA  
**Tempo:** 5 minutos  

**Pré-requisito - Maven:**
```bash
choco install maven
mvn --version
```

**Compilar:**
```bash
cd LambdaValidaPessoa
mvn clean package
```

**Verificar:**
```bash
ls -la target/ValidaPessoa-1.0.jar
```

---

### ☐ 3. Terraform Não Instalado
**Status:** ❌ FALTANDO  
**Prioridade:** 🔴 CRÍTICA  
**Tempo:** 5 minutos  

**Instalar:**
```bash
choco install terraform
# OU: https://www.terraform.io/downloads
```

**Verificar:**
```bash
terraform --version
```

---

### ☐ 4. Arquivo terraform.tfvars Não Criado
**Status:** ❌ FALTANDO  
**Prioridade:** 🔴 CRÍTICA  
**Tempo:** 10 minutos  

**Criar:**
```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

**Editar variáveis OBRIGATÓRIAS:**

```hcl
# 1. JWT Secret (mínimo 32 caracteres) - CRÍTICO!
jwt_secret = "___________________________________"

# 2. Senha PostgreSQL - CRÍTICO!
db_password = "___________________________________"

# 3. Email para alertas
alert_email_recipients = "___________________________________"
```

**Gerar JWT Secret:**
```bash
# Git Bash/Linux
openssl rand -base64 48

# PowerShell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 48 | ForEach-Object {[char]$_})
```

**Verificar:**
```bash
grep -v "^#" terraform.tfvars | grep -v "^$" | head -10
```

---

## ⚠️ IMPORTANTES (Altamente Recomendadas)

### ☐ 5. Permissões IAM do Usuário AWS
**Status:** ⚠️ NÃO VERIFICADO  
**Prioridade:** 🟡 IMPORTANTE  
**Tempo:** 15 minutos (se precisar ajustar)  

**Verificar permissões atuais:**
```bash
aws iam get-user
aws iam list-attached-user-policies --user-name SEU_USUARIO
```

**Policies necessárias:**
- [ ] AWSLambdaFullAccess
- [ ] AmazonAPIGatewayAdministrator
- [ ] AmazonRDSFullAccess
- [ ] AmazonVPCFullAccess
- [ ] IAMFullAccess (ou IAMLimitedAccess)
- [ ] CloudWatchFullAccess
- [ ] SecretsManagerReadWrite

**Se não tiver permissões:**
1. Contatar administrador AWS
2. Ou adicionar via Console: IAM → Users → Seu usuário → Add permissions

---

### ☐ 6. Backend do Terraform (Produção)
**Status:** ⚠️ CONFIGURADO LOCALMENTE  
**Prioridade:** 🟡 IMPORTANTE (para produção)  
**Tempo:** 20 minutos  

**Status atual:** Backend local (estado em arquivo local)

**Para produção, configurar S3 backend:**

1. Criar bucket S3:
```bash
aws s3api create-bucket --bucket seu-bucket-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket seu-bucket-terraform-state \
  --versioning-configuration Status=Enabled
```

2. Criar tabela DynamoDB:
```bash
aws dynamodb create-table --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

3. Editar `infra/terraform/backend.tf`:
```terraform
terraform {
  backend "s3" {
    bucket         = "seu-bucket-terraform-state"
    key            = "valida-pessoa/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

**Para dev/teste:** Pode manter local, mas fazer backup do `terraform.tfstate`

---

## ℹ️ OPCIONAIS (Melhorias)

### ☐ 7. New Relic License Key
**Status:** ℹ️ OPCIONAL  
**Prioridade:** 🔵 BAIXA (mas recomendada)  
**Tempo:** 10 minutos  

**Para habilitar monitoramento avançado:**

1. Criar conta: https://newrelic.com/signup
2. Obter License Key: Account settings → API keys
3. Configurar em `terraform.tfvars`:
```hcl
new_relic_license_key = "sua-license-key"
enable_new_relic_monitoring = true
```

**Para desabilitar:**
```hcl
enable_new_relic_monitoring = false
new_relic_license_key = ""
```

---

### ☐ 8. Configurações de Alertas Adicionais
**Status:** ℹ️ OPCIONAL  
**Prioridade:** 🔵 BAIXA  
**Tempo:** 15 minutos  

**Slack (opcional):**
```hcl
enable_slack_notifications = true
slack_webhook_url = "https://hooks.slack.com/services/..."
slack_channel = "#alerts"
```

**PagerDuty (opcional):**
```hcl
enable_pagerduty = true
pagerduty_service_key = "sua-chave"
```

---

## 🔍 Script de Verificação Automática

### Verificar Todas as Configurações

**Windows:**
```bash
check-requirements.bat
```

**Linux/Mac:**
```bash
chmod +x check-requirements.sh
./check-requirements.sh
```

O script verifica:
- [x] Java 21
- [x] Maven
- [x] AWS CLI + credenciais
- [x] Terraform
- [x] JAR compilado
- [x] terraform.tfvars criado
- [x] Variáveis sensíveis alteradas
- [x] Região AWS configurada
- [x] Permissões IAM
- [x] Conectividade AWS

---

## 🚀 Sequência de Deploy

### Após Corrigir Configurações Críticas:

```bash
# 1. Verificar pré-requisitos
check-requirements.bat

# 2. Navegar para diretório Terraform
cd infra/terraform

# 3. Inicializar Terraform (primeira vez)
terraform init

# 4. Validar configuração
terraform validate

# 5. Planejar deploy (revisar mudanças)
terraform plan -out=tfplan

# 6. Aplicar infraestrutura
terraform apply tfplan

# 7. Obter outputs
terraform output

# 8. Testar API
curl -X POST $(terraform output -raw api_gateway_url) \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}'
```

---

## 📊 Resumo por Prioridade

### 🔴 CRÍTICAS (4 itens)
1. ❌ AWS CLI não configurada
2. ❌ JAR não compilado
3. ❌ Terraform não instalado
4. ❌ terraform.tfvars não criado

**Tempo total:** ~30 minutos  
**Impacto:** Deploy NÃO funciona sem essas

---

### 🟡 IMPORTANTES (2 itens)
5. ⚠️ Permissões IAM
6. ⚠️ Backend Terraform

**Tempo total:** ~35 minutos  
**Impacto:** Deploy pode funcionar, mas não é recomendado para produção

---

### 🔵 OPCIONAIS (2 itens)
7. ℹ️ New Relic License Key
8. ℹ️ Alertas adicionais

**Tempo total:** ~25 minutos  
**Impacto:** Funcionalidades extras de monitoramento

---

## 💡 Ordem Recomendada de Execução

### Para Deploy Rápido (Dev/Teste):
1. ✅ Instalar AWS CLI
2. ✅ Configurar credenciais AWS
3. ✅ Instalar Terraform
4. ✅ Instalar Maven (se necessário)
5. ✅ Compilar JAR
6. ✅ Criar terraform.tfvars
7. ✅ Editar jwt_secret e db_password
8. ✅ Deploy!

**Tempo estimado:** 30-40 minutos

---

### Para Deploy Produção:
1. ✅ Tudo acima +
2. ✅ Verificar permissões IAM
3. ✅ Configurar backend S3
4. ✅ Configurar New Relic
5. ✅ Configurar alertas
6. ✅ Revisar configurações de segurança
7. ✅ Alterar `environment = "prod"`
8. ✅ Aumentar recursos se necessário

**Tempo estimado:** 1-2 horas

---

## 🎯 Status Final

**Código da Aplicação:** ✅ 100% Completo  
**Infraestrutura (Terraform):** ✅ 100% Completo  
**Documentação:** ✅ 100% Completo  
**Configuração de Ambiente:** ❌ 0% (precisa ser feito)  

**Próxima ação:** Executar `check-requirements.bat` e seguir instruções

---

## 📚 Arquivos de Referência Criados

1. `CONFIGURACOES_FALTANTES_DEPLOY.md` - Análise detalhada completa
2. `RESUMO_CONFIGURACOES.md` - Resumo executivo
3. `check-requirements.bat` - Script de verificação Windows
4. `check-requirements.sh` - Script de verificação Linux
5. Este checklist

---

**Data:** 2025-12-02  
**Projeto:** Lambda Valida Pessoa  
**Versão:** 1.0

