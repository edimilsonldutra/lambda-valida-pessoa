@echo off
REM 🚀 Script de Configuração do CI/CD Pipeline (Windows)
REM Este script configura automaticamente o repositório para usar o CI/CD

echo.
echo 🚀 Configurando CI/CD Pipeline...
echo.

REM Verificar se está em um repositório git
if not exist .git (
    echo ❌ Este diretório não é um repositório git!
    exit /b 1
)

echo ✅ Repositório git detectado
echo.

REM Verificar se tem acesso ao GitHub CLI
where gh >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  GitHub CLI (gh) não encontrado. Algumas configurações precisarão ser feitas manualmente.
    set GH_CLI=false
) else (
    echo ✅ GitHub CLI detectado
    set GH_CLI=true
)

echo.
echo ℹ️  Verificando branch develop...

REM Verificar se branch develop existe
git show-ref --verify --quiet refs/heads/develop
if %ERRORLEVEL% NEQ 0 (
    echo ℹ️  Criando branch develop...
    git checkout -b develop
    git push -u origin develop
    echo ✅ Branch develop criada
) else (
    echo ✅ Branch develop já existe
)

REM Voltar para main
git checkout main 2>nul || git checkout master

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━��━━━━
echo ✅ Configuração básica do CI/CD concluída!
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

echo ⚠️  PRÓXIMOS PASSOS MANUAIS:
echo.
echo 1. 🔐 Configure os Secrets no GitHub:
echo    Settings → Secrets and variables → Actions → New repository secret
echo.
echo    Secrets necessários:
echo    - AWS_ACCESS_KEY_ID_DEV
echo    - AWS_SECRET_ACCESS_KEY_DEV
echo    - AWS_ACCESS_KEY_ID_PROD
echo    - AWS_SECRET_ACCESS_KEY_PROD
echo    - S3_DEPLOYMENT_BUCKET_DEV
echo    - S3_DEPLOYMENT_BUCKET_PROD
echo    - TERRAFORM_STATE_BUCKET
echo    - SONAR_TOKEN (opcional)
echo    - SONAR_ORGANIZATION (opcional)
echo    - SNYK_TOKEN (opcional)
echo    - SLACK_WEBHOOK_URL (opcional)
echo.
echo 2. 🔒 Configure Branch Protection no GitHub:
echo    Settings → Branches → Add rule
echo    - Branch: main (2 approvals, status checks required)
echo    - Branch: develop (1 approval, status checks required)
echo.
echo 3. 👥 Configure os Code Owners:
echo    Edite .github\CODEOWNERS com os times/usuários responsáveis
echo.
echo 4. 🌍 Configure Environments no GitHub:
echo    Settings → Environments
echo    - development (no protection)
echo    - production-approval (required reviewers)
echo    - production (required reviewers + wait time)
echo.
echo 5. ✅ Teste o pipeline:
echo    git checkout -b feature/test-ci
echo    git commit --allow-empty -m "test: CI pipeline"
echo    git push origin feature/test-ci
echo    Crie um PR no GitHub
echo.
echo 📚 Leia o guia completo: CICD_GUIDE.md
echo 🚀 Quick start: CICD_QUICKSTART.md
echo.
echo ✅ Configuração concluída com sucesso! 🎉

pause

