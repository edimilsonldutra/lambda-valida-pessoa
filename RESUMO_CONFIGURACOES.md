# 📋 Resumo Rápido - Configurações Faltantes

## ❌ Configurações CRÍTICAS que Impedem o Deploy

### 1. AWS CLI Não Configurada
```bash
# Instalar
choco install awscli

# Configurar
aws configure
# Informar: Access Key ID, Secret Access Key, região (us-east-1)
```

### 2. JAR da Lambda Não Compilado
```bash
cd LambdaValidaPessoa
mvn clean package
```

### 3. Terraform Não Instalado
```bash
choco install terraform
```

### 4. terraform.tfvars Não Criado
```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# EDITAR: jwt_secret, db_password
```

---

## ⚠️ Configurações IMPORTANTES

### 5. Permissões IAM
Usuário AWS precisa ter:
- AWSLambdaFullAccess
- AmazonAPIGatewayAdministrator
- AmazonRDSFullAccess
- AmazonVPCFullAccess
- IAMFullAccess
- CloudWatchFullAccess
- SecretsManagerReadWrite

### 6. Backend Terraform (Produção)
Estado local = risco de perda
Recomendado: Configurar S3 backend

---

## ℹ️ Configurações OPCIONAIS

### 7. New Relic Monitoring
```hcl
new_relic_license_key = "SUA_KEY"
enable_new_relic_monitoring = true
```

### 8. Alertas
```hcl
alert_email_recipients = "email@empresa.com"
```

---

## 🚀 Deploy em 5 Passos

```bash
# 1. Verificar pré-requisitos
check-requirements.bat

# 2. Compilar
cd LambdaValidaPessoa
mvn clean package
cd ..

# 3. Configurar
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# EDITAR terraform.tfvars

# 4. Deploy
terraform init
terraform plan
terraform apply

# 5. Testar
curl -X POST $(terraform output -raw api_gateway_url) \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}'
```

---

## 📄 Documentação Completa

Veja: **CONFIGURACOES_FALTANTES_DEPLOY.md**

