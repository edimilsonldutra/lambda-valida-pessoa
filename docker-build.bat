@echo off
REM Script para build da imagem Docker no Windows

echo.
echo ============================================================
echo    Construindo imagem Docker - Lambda Valida Pessoa
echo ============================================================
echo.

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Docker não está instalado
    echo        Instale de: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo [1/2] Construindo imagem Docker...
docker-compose build deploy

if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha ao construir imagem
    pause
    exit /b 1
)

echo.
echo [2/2] Imagem construída com sucesso!
echo.
echo ============================================================
echo.
echo Para executar:
echo   docker-compose run --rm deploy bash
echo.
echo Ou use o script de deploy:
echo   docker-deploy.bat
echo.
echo ============================================================
echo.

pause

