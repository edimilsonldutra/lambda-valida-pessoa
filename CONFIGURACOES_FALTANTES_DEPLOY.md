# ⚠️ Análise de Configurações Faltantes para Deploy na AWS

## 📋 Resumo Executivo

Análise completa das configurações necessárias para fazer o deploy do projeto **Lambda Valida Pessoa** na AWS.

## 🐳 **NOVA OPÇÃO: Deploy com Docker (RECOMENDADO)**

### ✨ Solução Simplificada com Docker

Se você não quiser instalar Java, Maven, AWS CLI e Terraform localmente, use Docker!

**Requisito único:** Docker Desktop

**Vantagens:**
- ✅ Não precisa instalar Java 21
- ✅ Não precisa instalar Maven
- ✅ Não precisa instalar AWS CLI
- ✅ Não precisa instalar Terraform
- ✅ Funciona em Windows, Mac e Linux
- ✅ Ambiente isolado e reproduzível

**Como usar:**
```bash
# 1. Instalar Docker Desktop
# https://www.docker.com/products/docker-desktop

# 2. Construir imagem (automático, inclui todas as ferramentas)
docker-build.bat  # Windows
./docker-build.sh  # Linux/Mac

# 3. Deploy
docker-deploy.bat  # Windows
./docker-deploy.sh  # Linux/Mac
```

**Documentação completa:** Veja `DOCKER_DEPLOYMENT.md`

---

## 📌 Escolha Seu Caminho

### Opção A: Deploy com Docker (Recomendado) 🐳
- **Pré-requisito:** Docker Desktop
- **Tempo de setup:** ~15 minutos
- **Documentação:** `DOCKER_DEPLOYMENT.md`

### Opção B: Instalação Local (Tradicional) 💻
- **Pré-requisitos:** Java, Maven, AWS CLI, Terraform
- **Tempo de setup:** ~1 hora
- **Documentação:** Continue lendo este documento

---

## ✅ Configurações que EXISTEM no Projeto

### 1. Infraestrutura como Código (IaC)
- ✅ Arquivos Terraform completos (`infra/terraform/*.tf`)
- ✅ Template SAM (`template.yaml`)
- ✅ Scripts de deploy (`deploy.bat`, `deploy.sh`)
- ✅ Configurações de exemplo (`terraform.tfvars.example`)

### 2. Código da Aplicação
- ✅ Lambda Function Java 21 completa
- ✅ POM.xml com dependências corretas
- ✅ Handlers e Models configurados
- ✅ Integração New Relic configurada no código

---

## ❌ Configurações FALTANTES e Obrigatórias

### 🔴 **CRÍTICO 1: AWS CLI Não Configurada**

**Problema:** O AWS CLI não está instalado ou configurado.

**Solução:**

#### Passo 1: Instalar AWS CLI
```bash
# Windows (usando Chocolatey)
choco install awscli

# Ou baixe o instalador MSI:
# https://awscli.amazonaws.com/AWSCLIV2.msi
```

#### Passo 2: Configurar Credenciais AWS
```bash
aws configure
```

Você precisará fornecer:
- **AWS Access Key ID**: (obtido no IAM Console)
- **AWS Secret Access Key**: (obtido no IAM Console)
- **Default region**: `us-east-1` (ou sua região preferida)
- **Default output format**: `json`

#### Passo 3: Verificar Configuração
```bash
aws sts get-caller-identity
```

**Onde obter as credenciais:**
1. Acesse: https://console.aws.amazon.com/iam/
2. Vá em: **Users** → Seu usuário → **Security credentials**
3. Clique em: **Create access key**
4. Salve o Access Key ID e Secret Access Key

---

### 🔴 **CRÍTICO 2: JAR da Lambda Não Compilado**

**Problema:** O arquivo JAR não existe em `LambdaValidaPessoa/target/`

**Solução:**

#### Passo 1: Verificar Maven
```bash
mvn --version
```

Se não estiver instalado:
```bash
# Windows (usando Chocolatey)
choco install maven

# Ou baixe de:
# https://maven.apache.org/download.cgi
```

#### Passo 2: Compilar o Projeto
```bash
cd "C:\Users\Meu Computador\OneDrive\Área de Trabalho\FIAP\projeto\fase_tres\lambda-valida-pessoa\LambdaValidaPessoa"
mvn clean package
```

**Resultado Esperado:**
```
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

O JAR será criado em: `target/ValidaPessoa-1.0.jar`

---

### 🔴 **CRÍTICO 3: Terraform Não Instalado**

**Problema:** Terraform não está instalado.

**Solução:**

```bash
# Windows (usando Chocolatey)
choco install terraform

# Ou baixe de:
# https://www.terraform.io/downloads
```

**Verificar instalação:**
```bash
terraform --version
```

---

### 🟡 **IMPORTANTE 4: Arquivo terraform.tfvars Faltando**

**Problema:** O arquivo `terraform.tfvars` não foi criado a partir do exemplo.

**Solução:**

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

**Editar as seguintes variáveis OBRIGATÓRIAS:**

```hcl
# ============================================================================
# Configurações OBRIGATÓRIAS que você DEVE alterar
# ============================================================================

# 1. JWT Secret - CRÍTICO: Use um valor forte e aleatório
jwt_secret = "SUA_CHAVE_SECRETA_MINIMO_32_CARACTERES_MUITO_FORTE_E_ALEATORIA"

# 2. Senha do Banco de Dados - CRÍTICO: Use uma senha forte
db_password = "SenhaSuperForteDoPostgreSQL123!@#"

# 3. New Relic License Key (opcional, mas recomendado)
new_relic_license_key = "SUA_LICENSE_KEY_DO_NEW_RELIC"

# 4. Email para alertas
alert_email_recipients = "seu-email@empresa.com"
```

**Como gerar JWT Secret forte:**

```bash
# Linux/Mac/Git Bash
openssl rand -base64 48

# PowerShell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 48 | ForEach-Object {[char]$_})
```

---

### 🟡 **IMPORTANTE 5: Backend do Terraform Não Configurado**

**Problema:** O backend S3 está comentado em `backend.tf`, o que significa que o estado do Terraform será local.

**Impacto:** 
- ⚠️ Se perder o arquivo `terraform.tfstate`, não conseguirá gerenciar a infraestrutura
- ⚠️ Não é recomendado para produção ou trabalho em equipe

**Solução Recomendada para Produção:**

#### Passo 1: Criar bucket S3 para estado
```bash
aws s3api create-bucket \
  --bucket seu-bucket-terraform-state-lambda-valida \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket seu-bucket-terraform-state-lambda-valida \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket seu-bucket-terraform-state-lambda-valida \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

#### Passo 2: Criar tabela DynamoDB para lock
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

#### Passo 3: Editar `backend.tf`
```terraform
terraform {
  backend "s3" {
    bucket         = "seu-bucket-terraform-state-lambda-valida"
    key            = "valida-pessoa/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

**Solução Simplificada para Dev/Teste:**
- Pode deixar como está (backend local)
- **MAS:** Faça backup do arquivo `terraform.tfstate` após cada deploy

---

### 🟡 **IMPORTANTE 6: Permissões IAM Necessárias**

**Problema:** O usuário AWS precisa ter permissões adequadas.

**Permissões Mínimas Necessárias:**

1. **Lambda**: Criar e gerenciar funções Lambda
2. **API Gateway**: Criar e gerenciar APIs
3. **RDS**: Criar e gerenciar instâncias PostgreSQL
4. **VPC**: Criar VPC, Subnets, Security Groups, NAT Gateways
5. **IAM**: Criar roles e policies
6. **CloudWatch**: Criar log groups e alarmes
7. **Secrets Manager**: Criar e gerenciar secrets
8. **S3**: Gerenciar buckets (para Terraform state)

**Policy Recomendada:**

Anexar ao seu usuário IAM as seguintes policies gerenciadas:
- `AWSLambdaFullAccess`
- `AmazonAPIGatewayAdministrator`
- `AmazonRDSFullAccess`
- `AmazonVPCFullAccess`
- `IAMFullAccess` (ou `IAMLimitedAccess` se preferir restringir)
- `CloudWatchFullAccess`
- `SecretsManagerReadWrite`

Ou crie uma policy customizada com permissões específicas.

---

### 🟢 **OPCIONAL 7: New Relic License Key**

**Problema:** O monitoramento New Relic não funcionará sem a license key.

**Solução:**

1. Criar conta gratuita: https://newrelic.com/signup
2. Obter License Key:
   - Login → Account settings → API keys
   - Copiar "License key"
3. Adicionar no `terraform.tfvars`:
   ```hcl
   new_relic_license_key = "sua-license-key-aqui"
   enable_new_relic_monitoring = true
   ```

**Se não quiser usar New Relic:**
```hcl
enable_new_relic_monitoring = false
new_relic_license_key = ""
```

---

### 🟢 **OPCIONAL 8: Configurações de Alertas**

**Atualmente configurado mas não validado:**

```hcl
# No terraform.tfvars, configure:
alert_email_recipients = "seu-email@empresa.com"

# Opcional - Slack
enable_slack_notifications = true
slack_webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Opcional - PagerDuty
enable_pagerduty = true
pagerduty_service_key = "sua-chave-pagerduty"
```

---

## 📝 Checklist Completo de Deploy

### Antes do Deploy

- [ ] **1. AWS CLI instalado e configurado**
  ```bash
  aws --version
  aws sts get-caller-identity
  ```

- [ ] **2. Terraform instalado**
  ```bash
  terraform --version
  ```

- [ ] **3. Maven instalado**
  ```bash
  mvn --version
  ```

- [ ] **4. Java 21 instalado**
  ```bash
  java --version
  ```

- [ ] **5. JAR compilado**
  ```bash
  cd LambdaValidaPessoa
  mvn clean package
  ls -la target/ValidaPessoa-1.0.jar
  ```

- [ ] **6. terraform.tfvars criado e editado**
  ```bash
  cd infra/terraform
  cp terraform.tfvars.example terraform.tfvars
  # Editar: jwt_secret, db_password, new_relic_license_key
  ```

- [ ] **7. Permissões IAM corretas**
  - Verificar se o usuário tem permissões necessárias

- [ ] **8. Região AWS escolhida**
  - Padrão: `us-east-1`
  - Pode alterar em `terraform.tfvars`: `aws_region = "sa-east-1"` (São Paulo)

---

### Durante o Deploy

- [ ] **9. Terraform Init**
  ```bash
  cd infra/terraform
  terraform init
  ```

- [ ] **10. Terraform Plan**
  ```bash
  terraform plan -out=tfplan
  ```

- [ ] **11. Revisar o plano**
  - Verificar recursos que serão criados
  - Verificar custos estimados

- [ ] **12. Terraform Apply**
  ```bash
  terraform apply tfplan
  ```

---

### Após o Deploy

- [ ] **13. Verificar outputs**
  ```bash
  terraform output
  ```

- [ ] **14. Testar API**
  ```bash
  API_URL=$(terraform output -raw api_gateway_url)
  curl -X POST $API_URL \
    -H "Content-Type: application/json" \
    -d '{"cpf":"11144477735"}'
  ```

- [ ] **15. Verificar logs CloudWatch**
  ```bash
  aws logs tail /aws/lambda/valida-pessoa-dev-lambda --follow
  ```

- [ ] **16. Verificar New Relic (se habilitado)**
  - Acessar: https://one.newrelic.com
  - Verificar APM & Services

---

## 💰 Estimativa de Custos AWS

### Recursos que Serão Criados

| Recurso | Tipo | Custo Mensal Estimado (Dev) |
|---------|------|----------------------------|
| Lambda | On-demand | ~$0.20 (1M requests) |
| API Gateway | Pay-per-use | ~$3.50 (1M requests) |
| RDS PostgreSQL | `db.t4g.micro` | ~$12.00 |
| VPC | NAT Gateway | ~$32.00 |
| CloudWatch Logs | 1GB retention | ~$0.50 |
| Secrets Manager | 1 secret | ~$0.40 |
| **TOTAL** | | **~$48.60/mês** |

**Nota:** Para ambiente de desenvolvimento, considere:
- Desligar RDS quando não estiver usando
- Usar `enable_nat_gateway = false` (mas Lambda não terá acesso à internet)
- Usar DynamoDB ao invés de RDS (mais barato para baixo volume)

---

## 🔧 Problemas Comuns e Soluções

### Erro: "Access Denied"
```
Error: Error creating Lambda function: AccessDeniedException
```
**Solução:** Verificar permissões IAM do usuário AWS

### Erro: "JAR file not found"
```
Error: Error reading file: no such file or directory
```
**Solução:** Compilar o projeto primeiro com `mvn clean package`

### Erro: "Invalid JWT secret"
```
Error: JWT secret must be at least 32 characters long
```
**Solução:** Usar um JWT secret com no mínimo 32 caracteres

### Erro: "Subnet not available in AZ"
```
Error: Error creating DB Subnet Group: InvalidSubnet
```
**Solução:** Verificar se a região suporta as AZs configuradas

### Erro: "New Relic layer not found"
```
Error: Error creating Lambda function: InvalidParameterValueException
```
**Solução:** Atualizar o ARN do layer New Relic para sua região:
```hcl
# Para us-east-1
new_relic_lambda_layer_arn = "arn:aws:lambda:us-east-1:451483290750:layer:NewRelicJava21:1"

# Para sa-east-1 (São Paulo)
new_relic_lambda_layer_arn = "arn:aws:lambda:sa-east-1:451483290750:layer:NewRelicJava21:1"
```

---

## 🚀 Deployment Rápido (Resumo)

Para fazer deploy AGORA, execute estes comandos:

```bash
# 1. Configurar AWS (apenas primeira vez)
aws configure
# Informar: Access Key, Secret Key, Região (us-east-1)

# 2. Compilar aplicação
cd "C:\Users\Meu Computador\OneDrive\Área de Trabalho\FIAP\projeto\fase_tres\lambda-valida-pessoa\LambdaValidaPessoa"
mvn clean package

# 3. Configurar Terraform
cd ../infra/terraform
cp terraform.tfvars.example terraform.tfvars

# 4. EDITAR terraform.tfvars (OBRIGATÓRIO!)
# Alterar: jwt_secret, db_password

# 5. Deploy
terraform init
terraform plan
terraform apply

# 6. Testar
API_URL=$(terraform output -raw api_gateway_url)
curl -X POST $API_URL -H "Content-Type: application/json" -d '{"cpf":"11144477735"}'
```

---

## 📞 Suporte e Documentação

### Documentação Adicional no Projeto
- `README.md` - Visão geral do projeto
- `BUILD_INSTRUCTIONS.md` - Instruções de build
- `QUICK_START_MONITORING.md` - Setup do New Relic
- `infra/terraform/README.md` - Documentação do Terraform

### Links Úteis
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform Download](https://www.terraform.io/downloads)
- [Maven Download](https://maven.apache.org/download.cgi)
- [New Relic Signup](https://newrelic.com/signup)

---

## ✅ Conclusão

### Configurações Faltantes CRÍTICAS:
1. ❌ **AWS CLI não configurado** - Necessário instalar e configurar credenciais
2. ❌ **JAR não compilado** - Necessário executar `mvn clean package`
3. ❌ **Terraform não instalado** - Necessário instalar
4. ❌ **terraform.tfvars não criado** - Necessário criar e editar variáveis sensíveis

### Configurações Faltantes IMPORTANTES:
5. ⚠️ **Backend S3 não configurado** - Recomendado para produção
6. ⚠️ **Permissões IAM** - Verificar se usuário tem permissões adequadas

### Configurações OPCIONAIS:
7. ℹ️ **New Relic License Key** - Para monitoramento avançado
8. ℹ️ **Configurações de alertas** - Email, Slack, PagerDuty

**Após corrigir as configurações CRÍTICAS, o deploy funcionará.**

---

**Data da Análise:** 2025-12-02  
**Versão do Projeto:** 1.0  
**Ambiente:** AWS com Terraform

