@echo off
REM Script de deploy completo da aplicação para Windows
REM Este script automatiza o processo de build e deploy

echo.
echo ==========================================
echo    Lambda Valida Pessoa - Deploy Script
echo ==========================================
echo.

REM 1. Build da aplicação Java
echo [Step 1] Building Java application...
cd HelloWorldFunction
call mvn clean package

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Falha no build da aplicação
    pause
    exit /b 1
)

echo SUCCESS: Build concluído com sucesso!
cd ..

REM 2. Verificar se terraform.tfvars existe
echo.
echo [Step 2] Verificando configuração do Terraform...
if not exist "terraform\terraform.tfvars" (
    echo WARNING: terraform.tfvars não encontrado
    echo Criando a partir do exemplo...
    copy terraform\terraform.tfvars.example terraform\terraform.tfvars
    echo.
    echo ATENÇÃO: Edite terraform\terraform.tfvars antes de continuar!
    echo Especialmente o JWT_SECRET em produção!
    pause
    exit /b 1
)

REM 3. Terraform init
echo.
echo [Step 3] Inicializando Terraform...
cd terraform
terraform init

REM 4. Terraform plan
echo.
echo [Step 4] Planejando deploy...
terraform plan -out=tfplan

REM 5. Confirmar deploy
echo.
set /p confirm="Deseja aplicar o deploy? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo Deploy cancelado
    del tfplan
    pause
    exit /b 0
)

REM 6. Terraform apply
echo.
echo [Step 5] Aplicando infraestrutura...
terraform apply tfplan
del tfplan

REM 7. Obter outputs
echo.
echo [Step 6] Obtendo informações de deploy...
for /f "tokens=*" %%i in ('terraform output -raw api_gateway_url') do set API_URL=%%i
for /f "tokens=*" %%i in ('terraform output -raw lambda_function_name') do set LAMBDA_NAME=%%i
for /f "tokens=*" %%i in ('terraform output -raw dynamodb_table_name') do set DYNAMODB_TABLE=%%i

echo.
echo =========================================
echo     Deploy concluído com sucesso!
echo =========================================
echo.
echo API Gateway URL: %API_URL%
echo Lambda Function: %LAMBDA_NAME%
echo DynamoDB Table: %DYNAMODB_TABLE%
echo.
echo =========================================
echo.
echo Exemplo de teste:
echo.
echo curl -X POST %API_URL% ^
echo   -H "Content-Type: application/json" ^
echo   -d "{\"cpf\":\"11144477735\"}"
echo.
echo CPFs de teste disponíveis:
echo   * 11144477735 - João Silva (ACTIVE)
echo   * 52998224725 - Maria Santos (ACTIVE)
echo   * 70987206109 - Pedro Oliveira (INACTIVE)
echo.

cd ..
pause

