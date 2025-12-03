#!/bin/bash

# 🚀 Script de Configuração do CI/CD Pipeline
# Este script configura automaticamente o repositório para usar o CI/CD

set -e

echo "🚀 Configurando CI/CD Pipeline..."
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para printar mensagens
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "ℹ️  $1"
}

# Verificar se está em um repositório git
if [ ! -d .git ]; then
    print_error "Este diretório não é um repositório git!"
    exit 1
fi

print_success "Repositório git detectado"

# Verificar se tem acesso ao GitHub CLI
if ! command -v gh &> /dev/null; then
    print_warning "GitHub CLI (gh) não encontrado. Algumas configurações precisarão ser feitas manualmente."
    GH_CLI=false
else
    print_success "GitHub CLI detectado"
    GH_CLI=true
fi

# Criar branch develop se não existir
print_info "Verificando branch develop..."
if ! git show-ref --verify --quiet refs/heads/develop; then
    print_info "Criando branch develop..."
    git checkout -b develop
    git push -u origin develop
    print_success "Branch develop criada"
else
    print_success "Branch develop já existe"
fi

# Voltar para main
git checkout main 2>/dev/null || git checkout master

# Configurar Branch Protection Rules (via GitHub CLI)
if [ "$GH_CLI" = true ]; then
    print_info "Configurando proteção da branch main..."

    gh api repos/:owner/:repo/branches/main/protection -X PUT --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["CI Pipeline Success", "Build & Unit Tests", "Security Scan"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {},
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 2
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
EOF

    print_success "Proteção da branch main configurada"

    print_info "Configurando proteção da branch develop..."

    gh api repos/:owner/:repo/branches/develop/protection -X PUT --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Build & Unit Tests", "Code Quality Analysis"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {},
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
EOF

    print_success "Proteção da branch develop configurada"
fi

# Criar environments via GitHub CLI
if [ "$GH_CLI" = true ]; then
    print_info "Criando environments..."

    # Development
    gh api repos/:owner/:repo/environments/development -X PUT
    print_success "Environment 'development' criado"

    # Production Approval
    gh api repos/:owner/:repo/environments/production-approval -X PUT
    print_success "Environment 'production-approval' criado"

    # Production
    gh api repos/:owner/:repo/environments/production -X PUT
    print_success "Environment 'production' criado"

    # Development Infra
    gh api repos/:owner/:repo/environments/development-infra -X PUT
    print_success "Environment 'development-infra' criado"

    # Production Infra
    gh api repos/:owner/:repo/environments/production-infra -X PUT
    print_success "Environment 'production-infra' criado"
fi

# Criar labels úteis
if [ "$GH_CLI" = true ]; then
    print_info "Criando labels..."

    labels=(
        "bug:d73a4a:Something isn't working"
        "enhancement:a2eeef:New feature or request"
        "documentation:0075ca:Improvements or additions to documentation"
        "infrastructure:fbca04:Infrastructure changes"
        "ci/cd:5319e7:CI/CD pipeline changes"
        "security:d73a4a:Security related"
        "performance:0e8a16:Performance improvements"
        "test:bfd4f2:Test related"
        "size/xs:00ff00:Extra small PR"
        "size/s:77dd77:Small PR"
        "size/m:ffaa00:Medium PR"
        "size/l:ff6600:Large PR"
        "size/xl:ff0000:Extra large PR"
        "type: lambda:1d76db:Lambda function changes"
        "type: infrastructure:fbca04:Infrastructure changes"
        "type: ci/cd:5319e7:CI/CD changes"
        "type: tests:bfd4f2:Test changes"
        "type: documentation:0075ca:Documentation changes"
        "area: monitoring:0e8a16:Monitoring related"
        "area: security:d73a4a:Security related"
        "sync:ededed:Automated sync PR"
        "automated:ededed:Automated PR"
        "release:00ff00:Release related"
    )

    for label in "${labels[@]}"; do
        IFS=':' read -r name color description <<< "$label"
        gh label create "$name" --color "$color" --description "$description" 2>/dev/null || true
    done

    print_success "Labels criados"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "Configuração básica do CI/CD concluída!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_warning "PRÓXIMOS PASSOS MANUAIS:"
echo ""
echo "1. 🔐 Configure os Secrets no GitHub:"
echo "   Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "   Secrets necessários:"
echo "   - AWS_ACCESS_KEY_ID_DEV"
echo "   - AWS_SECRET_ACCESS_KEY_DEV"
echo "   - AWS_ACCESS_KEY_ID_PROD"
echo "   - AWS_SECRET_ACCESS_KEY_PROD"
echo "   - S3_DEPLOYMENT_BUCKET_DEV"
echo "   - S3_DEPLOYMENT_BUCKET_PROD"
echo "   - TERRAFORM_STATE_BUCKET"
echo "   - SONAR_TOKEN (opcional)"
echo "   - SONAR_ORGANIZATION (opcional)"
echo "   - SNYK_TOKEN (opcional)"
echo "   - SLACK_WEBHOOK_URL (opcional)"
echo ""
echo "2. 👥 Configure os Code Owners:"
echo "   Edite .github/CODEOWNERS com os times/usuários responsáveis"
echo ""
echo "3. 🔒 Configure Environment Protection Rules:"
echo "   Settings → Environments → [environment] → Protection rules"
echo "   - production: Adicione 2-3 required reviewers"
echo "   - production-approval: Adicione required reviewers"
echo ""
echo "4. 📧 Configure notificações (opcional):"
echo "   - Slack webhook"
echo "   - Email SMTP"
echo ""
echo "5. ✅ Teste o pipeline:"
echo "   - Crie uma branch: git checkout -b feature/test-ci"
echo "   - Faça um commit: git commit --allow-empty -m 'test: CI pipeline'"
echo "   - Push: git push origin feature/test-ci"
echo "   - Crie um PR no GitHub"
echo ""

print_info "📚 Leia o guia completo: CICD_GUIDE.md"
print_info "🚀 Quick start: CICD_QUICKSTART.md"

echo ""
print_success "Configuração concluída com sucesso! 🎉"

