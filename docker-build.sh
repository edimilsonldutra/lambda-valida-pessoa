#!/bin/bash
# Script para build da imagem Docker no Linux/Mac

set -e

echo ""
echo "============================================================"
echo "   Construindo imagem Docker - Lambda Valida Pessoa"
echo "============================================================"
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "[ERRO] Docker não está instalado"
    echo "       Instale de: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "[1/2] Construindo imagem Docker..."
docker-compose build deploy

echo ""
echo "[2/2] Imagem construída com sucesso!"
echo ""
echo "============================================================"
echo ""
echo "Para executar:"
echo "  docker-compose run --rm deploy bash"
echo ""
echo "Ou use o script de deploy:"
echo "  ./docker-deploy.sh"
echo ""
echo "============================================================"
echo ""

