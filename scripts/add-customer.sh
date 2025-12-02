#!/bin/bash

# Script para adicionar novos clientes no DynamoDB
# Usage: ./add-customer.sh <CPF> <NAME> <EMAIL> <STATUS>

set -e

# Validar argumentos
if [ "$#" -ne 4 ]; then
    echo "Uso: $0 <CPF> <NAME> <EMAIL> <STATUS>"
    echo "Exemplo: $0 12345678901 \"João Silva\" \"joao@example.com\" ACTIVE"
    exit 1
fi

CPF=$1
NAME=$2
EMAIL=$3
STATUS=$4

# Remover formatação do CPF
CLEAN_CPF=$(echo $CPF | tr -d '.-')

# Nome da tabela (ajuste conforme necessário)
TABLE_NAME=${DYNAMODB_TABLE:-"valida-pessoa-customers-dev"}

echo "Adicionando cliente ao DynamoDB..."
echo "CPF: $CLEAN_CPF"
echo "Name: $NAME"
echo "Email: $EMAIL"
echo "Status: $STATUS"
echo "Table: $TABLE_NAME"

aws dynamodb put-item \
    --table-name $TABLE_NAME \
    --item '{
        "cpf": {"S": "'$CLEAN_CPF'"},
        "name": {"S": "'$NAME'"},
        "email": {"S": "'$EMAIL'"},
        "status": {"S": "'$STATUS'"}
    }'

echo "✅ Cliente adicionado com sucesso!"

