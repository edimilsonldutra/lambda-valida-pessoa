@echo off
REM ==============================================================================
REM Script de Preparação para Deploy na AWS (Windows)
REM ==============================================================================
REM Este script prepara o projeto para deploy na AWS corrigindo as configurações
REM faltantes identificadas na análise.
REM ==============================================================================

setlocal enabledelayedexpansion

echo.
echo ================================================================================
echo   Preparacao para Deploy na AWS - Lambda Valida Pessoa
echo ================================================================================
echo.

REM ==============================================================================
REM STEP 0: Verificar pré-requisitos
REM ==============================================================================
echo [Step 0] Verificando pre-requisitos...
echo.

REM Check Java
where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Java nao encontrado! Instale Java 21
    exit /b 1
)
java -version 2>&1 | findstr /C:"version"
echo [OK] Java encontrado
echo.

REM Check Maven
where mvn >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Maven nao encontrado! Instale Maven
    exit /b 1
)
echo [OK] Maven encontrado
echo.

REM Check AWS CLI
where aws >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] AWS CLI nao encontrado! Instale AWS CLI
    exit /b 1
)
echo [OK] AWS CLI encontrado
echo.

REM Check Terraform
where terraform >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Terraform nao encontrado! Instale Terraform
    exit /b 1
)
echo [OK] Terraform encontrado
echo.

REM ==============================================================================
REM STEP 1: Build Lambda JAR
REM ==============================================================================
echo [Step 1] Compilando Lambda JAR...
echo.

cd LambdaValidaPessoa

if not exist "pom.xml" (
    echo [ERRO] pom.xml nao encontrado!
    exit /b 1
)

call mvn clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha ao compilar o projeto Maven
    exit /b 1
)

if exist "target\ValidaPessoa-1.0.jar" (
    echo [OK] Lambda JAR compilado com sucesso
    dir target\ValidaPessoa-1.0.jar
) else (
    echo [ERRO] JAR nao encontrado apos build!
    exit /b 1
)

cd ..
echo.

REM ==============================================================================
REM STEP 2: Generate Secure Secrets
REM ==============================================================================
echo [Step 2] Gerando secrets seguros...
echo.

REM Generate JWT secret (32 random bytes = 64 hex chars)
for /f %%i in ('powershell -Command "[Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Maximum 256 }))"') do set JWT_SECRET=%%i
echo [OK] JWT Secret gerado

REM Generate DB password (24 random bytes = 32 hex chars)
for /f %%i in ('powershell -Command "[Convert]::ToBase64String((1..24 | ForEach-Object { Get-Random -Maximum 256 }))"') do set DB_PASSWORD=%%i
echo [OK] DB Password gerado
echo.

REM ==============================================================================
REM STEP 3: Create secrets file
REM ==============================================================================
echo [Step 3] Criando arquivo de configuracao de secrets...
echo.

(
echo # ==============================================================================
echo # ATENCAO: ARQUIVO SENSIVEL - NUNCA COMMITAR!
echo # ==============================================================================
echo # Este arquivo contem secrets gerados automaticamente.
echo # Certifique-se de que *.auto.tfvars esta no .gitignore
echo #
echo # Gerado em: %DATE% %TIME%
echo # ==============================================================================
echo.
echo # JWT Configuration
echo jwt_secret = "%JWT_SECRET%"
echo.
echo # Database Configuration
echo db_password = "%DB_PASSWORD%"
echo.
echo # ==============================================================================
echo # IMPORTANTE: Salve estes valores em um local seguro!
echo # ==============================================================================
) > infra\terraform\secrets.auto.tfvars

echo [OK] Arquivo criado: infra\terraform\secrets.auto.tfvars
echo [AVISO] IMPORTANTE: Adicione *.auto.tfvars ao .gitignore!
echo.

REM ==============================================================================
REM STEP 4: Update .gitignore
REM ==============================================================================
echo [Step 4] Atualizando .gitignore...
echo.

findstr /C:"*.auto.tfvars" .gitignore >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo. >> .gitignore
    echo # Terraform auto-generated secrets (NEVER COMMIT^) >> .gitignore
    echo *.auto.tfvars >> .gitignore
    echo secrets.auto.tfvars >> .gitignore
    echo [OK] Adicionado *.auto.tfvars ao .gitignore
) else (
    echo [OK] .gitignore ja contem *.auto.tfvars
)
echo.

REM ==============================================================================
REM STEP 5: Check vars.tf
REM ==============================================================================
echo [Step 5] Verificando vars.tf...
echo.

findstr /C:"variable \"db_secret_arn\"" infra\terraform\vars.tf >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [AVISO] Variavel db_secret_arn encontrada em vars.tf
    echo [AVISO] Esta variavel deve ser removida manualmente
    echo [AVISO] Veja ANALISE_CONFIGURACAO_DEPLOY_AWS.md secao 8
) else (
    echo [OK] vars.tf parece correto (sem variavel db_secret_arn^)
)
echo.

REM ==============================================================================
REM STEP 6: Verify AWS Credentials
REM ==============================================================================
echo [Step 6] Verificando credenciais AWS...
echo.

aws sts get-caller-identity >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Credenciais AWS configuradas
    aws sts get-caller-identity
) else (
    echo [ERRO] Credenciais AWS nao configuradas!
    echo.
    echo Configure as credenciais AWS com:
    echo   1. aws configure
    echo   2. Ou defina variaveis de ambiente:
    echo      set AWS_ACCESS_KEY_ID=...
    echo      set AWS_SECRET_ACCESS_KEY=...
    echo      set AWS_DEFAULT_REGION=us-east-1
    exit /b 1
)
echo.

REM ==============================================================================
REM STEP 7: Initialize Terraform
REM ==============================================================================
echo [Step 7] Inicializando Terraform...
echo.

cd infra\terraform

terraform init -upgrade
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha ao inicializar Terraform
    exit /b 1
)

echo [OK] Terraform inicializado
echo.

REM ==============================================================================
REM STEP 8: Validate Terraform
REM ==============================================================================
echo [Step 8] Validando configuracao Terraform...
echo.

terraform validate
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Validacao Terraform falhou!
    echo.
    echo Problemas comuns:
    echo   1. Remova 'variable db_secret_arn' de vars.tf
    echo   2. Atualize referencias para usar: aws_secretsmanager_secret.db.arn
    echo.
    echo Veja: ANALISE_CONFIGURACAO_DEPLOY_AWS.md para detalhes
    exit /b 1
)

echo [OK] Configuracao Terraform valida
cd ..\..
echo.

REM ==============================================================================
REM STEP 9: Save secrets backup
REM ==============================================================================
echo [Step 9] Criando backup de secrets...
echo.

(
echo # ==============================================================================
echo # BACKUP DE SECRETS - %DATE% %TIME%
echo # ==============================================================================
echo # ATENCAO: Arquivo sensivel! Guarde em local seguro e DELETE do repositorio
echo # ==============================================================================
echo.
echo JWT_SECRET=%JWT_SECRET%
echo DB_PASSWORD=%DB_PASSWORD%
echo.
echo # ==============================================================================
echo # Para usar estes valores:
echo # ==============================================================================
echo # 1. No Terraform (ja configurado em secrets.auto.tfvars^)
echo # 2. No GitHub Secrets:
echo #    - JWT_SECRET
echo #    - DB_PASSWORD
echo # 3. Em variaveis de ambiente locais (opcional^):
echo #    set JWT_SECRET=%JWT_SECRET%
echo #    set DB_PASSWORD=%DB_PASSWORD%
echo # ==============================================================================
) > .secrets-backup.txt

echo [OK] Backup salvo em: .secrets-backup.txt
echo [AVISO] DELETE este arquivo apos salvar os secrets em local seguro!
echo.

REM ==============================================================================
REM SUMMARY
REM ==============================================================================
echo.
echo ================================================================================
echo.
echo              [OK] PREPARACAO CONCLUIDA COM SUCESSO!
echo.
echo ================================================================================
echo.

echo [OK] Lambda JAR: LambdaValidaPessoa\target\ValidaPessoa-1.0.jar
echo [OK] Secrets: infra\terraform\secrets.auto.tfvars
echo [OK] AWS credentials verificadas
echo [OK] Terraform inicializado e validado
echo.

echo ================================================================================
echo   PROXIMOS PASSOS:
echo ================================================================================
echo.
echo 1. Revisar o plano de execucao:
echo    cd infra\terraform
echo    terraform plan
echo.
echo 2. Aplicar a infraestrutura (se o plan estiver OK^):
echo    terraform apply
echo.
echo 3. Testar a API apos deploy:
echo    # URL sera exibida nos outputs do Terraform
echo.

echo ================================================================================
echo   IMPORTANTE:
echo ================================================================================
echo.
echo   * Salve os secrets do arquivo .secrets-backup.txt em local seguro
echo   * DELETE o arquivo .secrets-backup.txt apos backup
echo   * Configure os GitHub Secrets para CI/CD funcionar
echo   * Revise ANALISE_CONFIGURACAO_DEPLOY_AWS.md para detalhes
echo.

echo ================================================================================
echo   ESTIMATIVA DE CUSTOS AWS:
echo ================================================================================
echo.
echo   * Lambda: ~$0.20/mes
echo   * RDS (db.t4g.micro^): ~$12.41/mes
echo   * NAT Gateway: ~$32.85/mes
echo   * API Gateway: ~$3.50/mes
echo   * Outros: ~$1.00/mes
echo   TOTAL ESTIMADO: ~$49.86/mes
echo.
echo   Para reduzir custos em dev:
echo   * Desabilite NAT Gateway: enable_nat_gateway = false
echo   * Use DynamoDB ao inves de RDS
echo.

pause

