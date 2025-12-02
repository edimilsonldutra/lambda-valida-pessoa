@echo off
REM Script para adicionar novos clientes no DynamoDB
REM Usage: add-customer.bat <CPF> <NAME> <EMAIL> <STATUS>

if "%~4"=="" (
    echo Uso: %0 ^<CPF^> ^<NAME^> ^<EMAIL^> ^<STATUS^>
    echo Exemplo: %0 12345678901 "João Silva" "joao@example.com" ACTIVE
    exit /b 1
)

set CPF=%~1
set NAME=%~2
set EMAIL=%~3
set STATUS=%~4

REM Remover formatação do CPF (simplesmente)
set CLEAN_CPF=%CPF:~0,11%

REM Nome da tabela (ajuste conforme necessário)
if "%DYNAMODB_TABLE%"=="" (
    set TABLE_NAME=valida-pessoa-customers-dev
) else (
    set TABLE_NAME=%DYNAMODB_TABLE%
)

echo Adicionando cliente ao DynamoDB...
echo CPF: %CLEAN_CPF%
echo Name: %NAME%
echo Email: %EMAIL%
echo Status: %STATUS%
echo Table: %TABLE_NAME%

aws dynamodb put-item ^
    --table-name %TABLE_NAME% ^
    --item "{\"cpf\": {\"S\": \"%CLEAN_CPF%\"}, \"name\": {\"S\": \"%NAME%\"}, \"email\": {\"S\": \"%EMAIL%\"}, \"status\": {\"S\": \"%STATUS%\"}}"

echo.
echo Cliente adicionado com sucesso!

