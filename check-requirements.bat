@echo off
exit /b 0

)
    exit /b 1
    echo.
    echo Para mais detalhes, consulte: CONFIGURACOES_FALTANTES_DEPLOY.md
if %ERRORS% GTR 0 (

echo.
echo ============================================================
echo.

)
    echo        Corrija os erros acima antes de fazer o deploy
    echo [ERRO] Verificação falhou com %ERRORS% erros
) else (
    )
        echo         Você pode prosseguir, mas revise os avisos acima
        echo [AVISO] Verificação concluída com %WARNINGS% avisos
    ) else (
        echo   terraform apply
        echo   terraform plan
        echo   terraform init
        echo   cd infra\terraform
        echo Execute:
        echo.
        echo           Você está pronto para fazer o deploy.
        echo [SUCESSO] Todas as verificações passaram!
    if %WARNINGS% EQU 0 (
if %ERRORS% EQU 0 (

echo.
echo ============================================================
echo                        RESUMO
echo ============================================================
REM Resumo

echo.
)
    set /a WARNINGS+=1
    echo         Verifique suas credenciais e conexão de internet
    echo [AVISO] Problema ao conectar com AWS
) else (
    echo [OK] Conectividade com AWS confirmada
if %ERRORLEVEL% EQU 0 (
aws ec2 describe-regions --region us-east-1 --max-items 1 >nul 2>&1
echo [10/10] Verificando conectividade com AWS...
REM Verificar conexão com AWS

echo.
)
    echo [SKIP] Arquivo terraform.tfvars não existe
) else (
    )
        echo        Para habilitar monitoramento, obtenha em: https://newrelic.com/signup
        echo [INFO] New Relic License Key não configurado (opcional)
    ) else (
        echo [OK] New Relic License Key parece configurado
    if %ERRORLEVEL% EQU 0 (
    findstr /C:"new_relic_license_key" infra\terraform\terraform.tfvars | findstr /V /C:"YOUR_NEW_RELIC" >nul 2>&1
if exist "infra\terraform\terraform.tfvars" (
echo [9/10] Verificando configuração New Relic (opcional)...
REM Verificar New Relic (opcional)

echo.
)
    set /a WARNINGS+=1
    echo         Certifique-se de ter as permissões necessárias
    echo [AVISO] Não foi possível verificar permissões IAM
) else (
    echo [OK] Acesso ao IAM confirmado
if %ERRORLEVEL% EQU 0 (
aws iam get-user >nul 2>&1
echo [8/10] Verificando permissões IAM básicas...
REM Verificar permissões IAM

echo.
)
    set /a WARNINGS+=1
    echo         Execute: aws configure
    echo [AVISO] Região AWS não configurada
) else (
    echo [OK] Região AWS: %AWS_REGION%
    for /f "tokens=*" %%i in ('aws configure get region') do set AWS_REGION=%%i
if %ERRORLEVEL% EQU 0 (
aws configure get region >nul 2>&1
echo [7/10] Verificando região AWS padrão...
REM Verificar região AWS

echo.
)
    set /a ERRORS+=1
    echo        Depois edite o arquivo com suas configurações
    echo        Execute: cd infra\terraform ^&^& copy terraform.tfvars.example terraform.tfvars
    echo [ERRO] Arquivo terraform.tfvars não encontrado
) else (

    )
        echo [OK] DB_PASSWORD parece configurado
    ) else (
        set /a WARNINGS+=1
        echo         Edite infra\terraform\terraform.tfvars e altere db_password
        echo [AVISO] DB_PASSWORD parece não ter sido alterado do exemplo
    if %ERRORLEVEL% EQU 0 (
    findstr /C:"CHANGE_THIS_PASSWORD" infra\terraform\terraform.tfvars >nul 2>&1
    REM Verificar se db_password foi alterado

    )
        echo [OK] JWT_SECRET parece configurado
    ) else (
        set /a WARNINGS+=1
        echo         Edite infra\terraform\terraform.tfvars e altere jwt_secret
        echo [AVISO] JWT_SECRET parece não ter sido alterado do exemplo
    if %ERRORLEVEL% EQU 0 (
    findstr /C:"your-secret-key-minimum-32-characters" infra\terraform\terraform.tfvars >nul 2>&1
    REM Verificar se jwt_secret foi alterado

    echo [OK] Arquivo terraform.tfvars encontrado
if exist "infra\terraform\terraform.tfvars" (
echo [6/10] Verificando terraform.tfvars...
REM Verificar terraform.tfvars

echo.
)
    set /a WARNINGS+=1
    echo         Execute: cd LambdaValidaPessoa ^&^& mvn clean package
    echo [AVISO] JAR não encontrado: %JAR_PATH%
) else (
    for %%I in ("%JAR_PATH%") do echo     Tamanho: %%~zI bytes
    echo [OK] JAR encontrado: %JAR_PATH%
if exist "%JAR_PATH%" (
set JAR_PATH=LambdaValidaPessoa\target\ValidaPessoa-1.0.jar
echo [5/10] Verificando JAR compilado...
REM Verificar JAR compilado

echo.
)
    set /a ERRORS+=1
    echo        Ou baixe de: https://www.terraform.io/downloads
    echo        Instale com: choco install terraform
    echo [ERRO] Terraform não encontrado
) else (
    terraform --version | findstr "Terraform"
    echo [OK] Terraform encontrado
if %ERRORLEVEL% EQU 0 (
terraform --version >nul 2>&1
echo [4/10] Verificando Terraform...
REM Verificar Terraform

echo.
)
    set /a ERRORS+=1
    echo        Ou baixe de: https://awscli.amazonaws.com/AWSCLIV2.msi
    echo        Instale com: choco install awscli
    echo [ERRO] AWS CLI não encontrado
) else (
    )
        set /a ERRORS+=1
        echo        Execute: aws configure
        echo [ERRO] Credenciais AWS não configuradas
    ) else (
        aws sts get-caller-identity
        echo [OK] Credenciais AWS configuradas
    if %ERRORLEVEL% EQU 0 (
    aws sts get-caller-identity >nul 2>&1
    echo     Verificando credenciais AWS...
    echo.
    aws --version
    echo [OK] AWS CLI encontrado
if %ERRORLEVEL% EQU 0 (
aws --version >nul 2>&1
echo [3/10] Verificando AWS CLI...
REM Verificar AWS CLI

echo.
)
    set /a ERRORS+=1
    echo        Ou baixe de: https://maven.apache.org/download.cgi
    echo        Instale com: choco install maven
    echo [ERRO] Maven não encontrado
) else (
    mvn --version | findstr "Apache Maven"
    echo [OK] Maven encontrado
if %ERRORLEVEL% EQU 0 (
mvn --version >nul 2>&1
echo [2/10] Verificando Maven...
REM Verificar Maven

echo.
)
    set /a ERRORS+=1
    echo        Instale de: https://www.oracle.com/java/technologies/downloads/#java21
    echo [ERRO] Java 21 não encontrado
) else (
    java -version 2>&1 | findstr "version"
    echo [OK] Java 21 encontrado
if %ERRORLEVEL% EQU 0 (
java -version 2>&1 | findstr "21" >nul
echo [1/10] Verificando Java 21...
REM Verificar Java

set WARNINGS=0
set ERRORS=0

echo.
echo ============================================================
echo    Verificador de Configurações - Lambda Valida Pessoa
echo ============================================================
echo.

REM Executa uma verificação completa de pré-requisitos
REM Script para verificar todas as configurações necessárias para deploy

