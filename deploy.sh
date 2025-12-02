#!/bin/bash

# Script de deploy completo da aplicação
# Este script automatiza o processo de build e deploy

set -e

echo "🚀 Iniciando deploy da Lambda Valida Pessoa..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Build da aplicação Java
print_info "Step 1: Building Java application..."
cd HelloWorldFunction
mvn clean package

if [ $? -eq 0 ]; then
    print_info "✅ Build concluído com sucesso!"
else
    print_error "Falha no build da aplicação"
    exit 1
fi

cd ..

# 2. Verificar se terraform.tfvars existe
print_info "Step 2: Verificando configuração do Terraform..."
if [ ! -f "terraform/terraform.tfvars" ]; then
    print_warning "terraform.tfvars não encontrado. Criando a partir do exemplo..."
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    print_warning "ATENÇÃO: Edite terraform/terraform.tfvars antes de continuar!"
    print_warning "Especialmente o JWT_SECRET em produção!"
    exit 1
fi

# 3. Terraform init
print_info "Step 3: Inicializando Terraform..."
cd terraform
terraform init

# 4. Terraform plan
print_info "Step 4: Planejando deploy..."
terraform plan -out=tfplan

# 5. Confirmar deploy
read -p "Deseja aplicar o deploy? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    print_warning "Deploy cancelado"
    rm -f tfplan
    exit 0
fi

# 6. Terraform apply
print_info "Step 5: Aplicando infraestrutura..."
terraform apply tfplan
rm -f tfplan

# 7. Obter outputs
print_info "Step 6: Obtendo informações de deploy..."
API_URL=$(terraform output -raw api_gateway_url)
LAMBDA_NAME=$(terraform output -raw lambda_function_name)
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)

echo ""
print_info "========================================="
print_info "✅ Deploy concluído com sucesso!"
print_info "========================================="
echo ""
echo "📡 API Gateway URL: $API_URL"
echo "🔧 Lambda Function: $LAMBDA_NAME"
echo "🗄️  DynamoDB Table: $DYNAMODB_TABLE"
echo ""
print_info "========================================="
echo ""

# 8. Exemplo de teste
print_info "Exemplo de teste:"
echo ""
echo "curl -X POST $API_URL \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"cpf\":\"11144477735\"}'"
echo ""

print_info "CPFs de teste disponíveis:"
echo "  • 11144477735 - João Silva (ACTIVE)"
echo "  • 52998224725 - Maria Santos (ACTIVE)"
echo "  • 70987206109 - Pedro Oliveira (INACTIVE)"
echo ""

cd ..

