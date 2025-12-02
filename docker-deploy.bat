@echo off
REM Script para fazer deploy usando Docker (Windows)

echo.
echo ============================================================
echo    Deploy AWS Lambda via Docker - Lambda Valida Pessoa
echo ============================================================
echo.

REM Verificar se Docker está rodando
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Docker não está rodando
    echo        Inicie o Docker Desktop e tente novamente
    pause
    exit /b 1
)

REM Verificar se a imagem existe
docker images lambda-valida-pessoa:latest -q >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Imagem não encontrada. Construindo...
    call docker-build.bat
)

echo [INFO] Iniciando container de deploy...
echo.

REM Verificar se .env existe
if not exist ".env" (
    echo [AVISO] Arquivo .env não encontrado
    echo         Criando a partir do exemplo...
    copy .env.example .env
    echo.
    echo [AÇÃO NECESSÁRIA] Edite o arquivo .env com suas credenciais AWS
    echo.
    pause
)

REM Verificar se terraform.tfvars existe
if not exist "infra\terraform\terraform.tfvars" (
    echo [AVISO] Arquivo terraform.tfvars não encontrado
    echo         Criando a partir do exemplo...
    copy infra\terraform\terraform.tfvars.example infra\terraform\terraform.tfvars
    echo.
    echo [AÇÃO NECESSÁRIA] Edite infra/terraform/terraform.tfvars
    echo                   Altere: jwt_secret, db_password
    echo.
    pause
)

echo ============================================================
echo   Entrando no container de deploy...
echo ============================================================
echo.
echo Comandos disponíveis dentro do container:
echo   - terraform -chdir=infra/terraform init
echo   - terraform -chdir=infra/terraform plan
echo   - terraform -chdir=infra/terraform apply
echo   - aws configure (se precisar configurar credenciais)
echo.
echo Para sair: digite 'exit'
echo.
echo ============================================================
echo.

docker-compose run --rm deploy bash

echo.
echo ============================================================
echo   Container encerrado
echo ============================================================
echo.

pause

