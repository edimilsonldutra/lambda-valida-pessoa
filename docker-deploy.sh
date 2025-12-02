#!/bin/bash
# Script para fazer deploy usando Docker (Linux/Mac)

set -e

echo ""
echo "============================================================"
echo "   Deploy AWS Lambda via Docker - Lambda Valida Pessoa"
echo "============================================================"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}[ERRO]${NC} Docker não está rodando"
    echo "       Inicie o Docker e tente novamente"
    exit 1
fi

# Verificar se a imagem existe
if ! docker images lambda-valida-pessoa:latest -q > /dev/null 2>&1; then
    echo -e "${YELLOW}[INFO]${NC} Imagem não encontrada. Construindo..."
    ./docker-build.sh
fi

echo -e "${GREEN}[INFO]${NC} Iniciando container de deploy..."
echo ""

# Verificar se .env existe
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}[AVISO]${NC} Arquivo .env não encontrado"
    echo "        Criando a partir do exemplo..."
    cp .env.example .env
    echo ""
    echo -e "${YELLOW}[AÇÃO NECESSÁRIA]${NC} Edite o arquivo .env com suas credenciais AWS"
    echo ""
    read -p "Pressione ENTER para continuar..."
fi

# Verificar se terraform.tfvars existe
if [ ! -f "infra/terraform/terraform.tfvars" ]; then
    echo -e "${YELLOW}[AVISO]${NC} Arquivo terraform.tfvars não encontrado"
    echo "        Criando a partir do exemplo..."
    cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
    echo ""
    echo -e "${YELLOW}[AÇÃO NECESSÁRIA]${NC} Edite infra/terraform/terraform.tfvars"
    echo "                  Altere: jwt_secret, db_password"
    echo ""
    read -p "Pressione ENTER para continuar..."
fi

echo "============================================================"
echo "   Entrando no container de deploy..."
echo "============================================================"
echo ""
echo "Comandos disponíveis dentro do container:"
echo "  - terraform -chdir=infra/terraform init"
echo "  - terraform -chdir=infra/terraform plan"
echo "  - terraform -chdir=infra/terraform apply"
echo "  - aws configure (se precisar configurar credenciais)"
echo ""
echo "Para sair: digite 'exit'"
echo ""
echo "============================================================"
echo ""

docker-compose run --rm deploy bash

echo ""
echo "============================================================"
echo "   Container encerrado"
echo "============================================================"
echo ""

