#!/bin/bash

# Script para verificar todas as configurações necessárias para deploy
# Executa uma verificação completa de pré-requisitos

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo ""
echo "============================================================"
echo "   Verificador de Configurações - Lambda Valida Pessoa"
echo "============================================================"
echo ""

# Função para imprimir status
print_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 1. Verificar Java
echo "[1/10] Verificando Java 21..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | grep -oP 'version "\K[0-9]+')
    if [ "$JAVA_VERSION" -eq "21" ]; then
        print_ok "Java 21 encontrado"
        java -version 2>&1 | head -1
    else
        print_error "Java $JAVA_VERSION encontrado, mas Java 21 é necessário"
        echo "       Instale de: https://www.oracle.com/java/technologies/downloads/#java21"
    fi
else
    print_error "Java não encontrado"
    echo "       Instale de: https://www.oracle.com/java/technologies/downloads/#java21"
fi
echo ""

# 2. Verificar Maven
echo "[2/10] Verificando Maven..."
if command -v mvn &> /dev/null; then
    print_ok "Maven encontrado"
    mvn --version | head -1
else
    print_error "Maven não encontrado"
    echo "       Instale de: https://maven.apache.org/download.cgi"
fi
echo ""

# 3. Verificar AWS CLI
echo "[3/10] Verificando AWS CLI..."
if command -v aws &> /dev/null; then
    print_ok "AWS CLI encontrado"
    aws --version
    echo ""
    echo "    Verificando credenciais AWS..."
    if aws sts get-caller-identity &> /dev/null; then
        print_ok "Credenciais AWS configuradas"
        aws sts get-caller-identity
    else
        print_error "Credenciais AWS não configuradas"
        echo "       Execute: aws configure"
    fi
else
    print_error "AWS CLI não encontrado"
    echo "       Instale de: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
fi
echo ""

# 4. Verificar Terraform
echo "[4/10] Verificando Terraform..."
if command -v terraform &> /dev/null; then
    print_ok "Terraform encontrado"
    terraform --version | head -1
else
    print_error "Terraform não encontrado"
    echo "       Instale de: https://www.terraform.io/downloads"
fi
echo ""

# 5. Verificar JAR compilado
echo "[5/10] Verificando JAR compilado..."
JAR_PATH="LambdaValidaPessoa/target/ValidaPessoa-1.0.jar"
if [ -f "$JAR_PATH" ]; then
    print_ok "JAR encontrado: $JAR_PATH"
    JAR_SIZE=$(stat -f%z "$JAR_PATH" 2>/dev/null || stat -c%s "$JAR_PATH" 2>/dev/null)
    echo "    Tamanho: $JAR_SIZE bytes"
else
    print_warning "JAR não encontrado: $JAR_PATH"
    echo "        Execute: cd LambdaValidaPessoa && mvn clean package"
fi
echo ""

# 6. Verificar terraform.tfvars
echo "[6/10] Verificando terraform.tfvars..."
if [ -f "infra/terraform/terraform.tfvars" ]; then
    print_ok "Arquivo terraform.tfvars encontrado"

    # Verificar se jwt_secret foi alterado
    if grep -q "your-secret-key-minimum-32-characters" infra/terraform/terraform.tfvars; then
        print_warning "JWT_SECRET parece não ter sido alterado do exemplo"
        echo "        Edite infra/terraform/terraform.tfvars e altere jwt_secret"
    else
        print_ok "JWT_SECRET parece configurado"
    fi

    # Verificar se db_password foi alterado
    if grep -q "CHANGE_THIS_PASSWORD" infra/terraform/terraform.tfvars; then
        print_warning "DB_PASSWORD parece não ter sido alterado do exemplo"
        echo "        Edite infra/terraform/terraform.tfvars e altere db_password"
    else
        print_ok "DB_PASSWORD parece configurado"
    fi
else
    print_error "Arquivo terraform.tfvars não encontrado"
    echo "       Execute: cd infra/terraform && cp terraform.tfvars.example terraform.tfvars"
    echo "       Depois edite o arquivo com suas configurações"
fi
echo ""

# 7. Verificar região AWS
echo "[7/10] Verificando região AWS padrão..."
AWS_REGION=$(aws configure get region 2>/dev/null || echo "")
if [ -n "$AWS_REGION" ]; then
    print_ok "Região AWS: $AWS_REGION"
else
    print_warning "Região AWS não configurada"
    echo "        Execute: aws configure"
fi
echo ""

# 8. Verificar permissões IAM
echo "[8/10] Verificando permissões IAM básicas..."
if aws iam get-user &> /dev/null; then
    print_ok "Acesso ao IAM confirmado"
else
    print_warning "Não foi possível verificar permissões IAM"
    echo "        Certifique-se de ter as permissões necessárias"
fi
echo ""

# 9. Verificar New Relic (opcional)
echo "[9/10] Verificando configuração New Relic (opcional)..."
if [ -f "infra/terraform/terraform.tfvars" ]; then
    if grep "new_relic_license_key" infra/terraform/terraform.tfvars | grep -v "YOUR_NEW_RELIC" &> /dev/null; then
        print_ok "New Relic License Key parece configurado"
    else
        print_info "New Relic License Key não configurado (opcional)"
        echo "       Para habilitar monitoramento, obtenha em: https://newrelic.com/signup"
    fi
else
    echo "[SKIP] Arquivo terraform.tfvars não existe"
fi
echo ""

# 10. Verificar conexão com AWS
echo "[10/10] Verificando conectividade com AWS..."
if aws ec2 describe-regions --region us-east-1 --max-items 1 &> /dev/null; then
    print_ok "Conectividade com AWS confirmada"
else
    print_warning "Problema ao conectar com AWS"
    echo "        Verifique suas credenciais e conexão de internet"
fi
echo ""

# Resumo
echo "============================================================"
echo "                       RESUMO"
echo "============================================================"
echo ""

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}[SUCESSO]${NC} Todas as verificações passaram!"
        echo "          Você está pronto para fazer o deploy."
        echo ""
        echo "Execute:"
        echo "  cd infra/terraform"
        echo "  terraform init"
        echo "  terraform plan"
        echo "  terraform apply"
    else
        echo -e "${YELLOW}[AVISO]${NC} Verificação concluída com $WARNINGS avisos"
        echo "        Você pode prosseguir, mas revise os avisos acima"
    fi
else
    echo -e "${RED}[ERRO]${NC} Verificação falhou com $ERRORS erros"
    echo "       Corrija os erros acima antes de fazer o deploy"
fi

echo ""
echo "============================================================"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "Para mais detalhes, consulte: CONFIGURACOES_FALTANTES_DEPLOY.md"
    echo ""
    exit 1
fi

exit 0

