#!/bin/bash
# ==============================================================================
# Script de Preparação para Deploy na AWS
# ==============================================================================
# Este script prepara o projeto para deploy na AWS corrigindo as configurações
# faltantes identificadas na análise.
# ==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# ==============================================================================
# STEP 0: Verificar pré-requisitos
# ==============================================================================
print_step "Step 0: Checking prerequisites..."

# Check Java
if ! command -v java &> /dev/null; then
    print_error "Java not found! Please install Java 21"
    exit 1
fi
print_success "Java found: $(java -version 2>&1 | head -n 1)"

# Check Maven
if ! command -v mvn &> /dev/null; then
    print_error "Maven not found! Please install Maven"
    exit 1
fi
print_success "Maven found: $(mvn -version | head -n 1)"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found! Please install AWS CLI"
    exit 1
fi
print_success "AWS CLI found: $(aws --version)"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform not found! Please install Terraform"
    exit 1
fi
print_success "Terraform found: $(terraform version | head -n 1)"

echo ""

# ==============================================================================
# STEP 1: Build Lambda JAR
# ==============================================================================
print_step "Step 1: Building Lambda JAR..."

cd LambdaValidaPessoa

if [ -f "pom.xml" ]; then
    mvn clean package -DskipTests

    if [ -f "target/ValidaPessoa-1.0.jar" ]; then
        print_success "Lambda JAR built successfully"
        ls -lh target/ValidaPessoa-1.0.jar
    else
        print_error "JAR file not found after build!"
        exit 1
    fi
else
    print_error "pom.xml not found!"
    exit 1
fi

cd ..
echo ""

# ==============================================================================
# STEP 2: Generate Secure Secrets
# ==============================================================================
print_step "Step 2: Generating secure secrets..."

# Generate JWT secret (base64, 48 bytes = 64 chars)
JWT_SECRET=$(openssl rand -base64 48)
print_success "JWT Secret generated (64 chars)"

# Generate DB password (base64, 24 bytes = 32 chars)
DB_PASSWORD=$(openssl rand -base64 24)
print_success "DB Password generated (32 chars)"

echo ""

# ==============================================================================
# STEP 3: Create secrets file
# ==============================================================================
print_step "Step 3: Creating secrets configuration file..."

cat > infra/terraform/secrets.auto.tfvars <<EOF
# ==============================================================================
# ⚠️  ATENÇÃO: ARQUIVO SENSÍVEL - NUNCA COMMITAR! ⚠️
# ==============================================================================
# Este arquivo contém secrets gerados automaticamente.
# Certifique-se de que *.auto.tfvars está no .gitignore
#
# Gerado em: $(date)
# ==============================================================================

# JWT Configuration
jwt_secret = "${JWT_SECRET}"

# Database Configuration
db_password = "${DB_PASSWORD}"

# ==============================================================================
# IMPORTANTE: Salve estes valores em um local seguro!
# ==============================================================================
EOF

print_success "Secrets file created: infra/terraform/secrets.auto.tfvars"
print_warning "IMPORTANTE: Adicione *.auto.tfvars ao .gitignore!"

echo ""

# ==============================================================================
# STEP 4: Update .gitignore
# ==============================================================================
print_step "Step 4: Updating .gitignore..."

if ! grep -q "*.auto.tfvars" .gitignore 2>/dev/null; then
    cat >> .gitignore <<EOF

# Terraform auto-generated secrets (NEVER COMMIT!)
*.auto.tfvars
secrets.auto.tfvars
EOF
    print_success "Added *.auto.tfvars to .gitignore"
else
    print_success ".gitignore already contains *.auto.tfvars"
fi

echo ""

# ==============================================================================
# STEP 5: Fix vars.tf (remove db_secret_arn variable)
# ==============================================================================
print_step "Step 5: Fixing vars.tf (removing db_secret_arn variable)..."

VARS_FILE="infra/terraform/vars.tf"

if grep -q "variable \"db_secret_arn\"" "$VARS_FILE"; then
    print_warning "Found db_secret_arn variable in vars.tf"
    print_warning "This should be removed manually - it's computed from secrets.tf"
    print_warning "See ANALISE_CONFIGURACAO_DEPLOY_AWS.md section 8 for details"
else
    print_success "vars.tf looks good (no db_secret_arn variable)"
fi

echo ""

# ==============================================================================
# STEP 6: Verify AWS Credentials
# ==============================================================================
print_step "Step 6: Verifying AWS credentials..."

if aws sts get-caller-identity &>/dev/null; then
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
    print_success "AWS credentials configured"
    echo "  Account: $AWS_ACCOUNT"
    echo "  User/Role: $AWS_USER"
else
    print_error "AWS credentials not configured!"
    echo ""
    echo "Configure AWS credentials with one of these methods:"
    echo "  1. Run: aws configure"
    echo "  2. Export environment variables:"
    echo "     export AWS_ACCESS_KEY_ID=..."
    echo "     export AWS_SECRET_ACCESS_KEY=..."
    echo "     export AWS_DEFAULT_REGION=us-east-1"
    exit 1
fi

echo ""

# ==============================================================================
# STEP 7: Initialize Terraform
# ==============================================================================
print_step "Step 7: Initializing Terraform..."

cd infra/terraform

terraform init -upgrade

print_success "Terraform initialized"

echo ""

# ==============================================================================
# STEP 8: Validate Terraform
# ==============================================================================
print_step "Step 8: Validating Terraform configuration..."

if terraform validate; then
    print_success "Terraform configuration is valid"
else
    print_error "Terraform validation failed!"
    echo ""
    print_warning "Common issues:"
    echo "  1. Remove 'variable db_secret_arn' from vars.tf"
    echo "  2. Update references to use: aws_secretsmanager_secret.db.arn"
    echo ""
    echo "See: ANALISE_CONFIGURACAO_DEPLOY_AWS.md for details"
    exit 1
fi

cd ../..

echo ""

# ==============================================================================
# STEP 9: Save secrets backup
# ==============================================================================
print_step "Step 9: Creating secrets backup..."

cat > .secrets-backup.txt <<EOF
# ==============================================================================
# BACKUP DE SECRETS - $(date)
# ==============================================================================
# ⚠️  ATENÇÃO: Arquivo sensível! Guarde em local seguro e DELETE do repositório
# ==============================================================================

JWT_SECRET=${JWT_SECRET}
DB_PASSWORD=${DB_PASSWORD}

# ==============================================================================
# Para usar estes valores:
# ==============================================================================
# 1. No Terraform (já configurado em secrets.auto.tfvars)
# 2. No GitHub Secrets:
#    - JWT_SECRET
#    - DB_PASSWORD
# 3. Em variáveis de ambiente locais (opcional):
#    export JWT_SECRET="${JWT_SECRET}"
#    export DB_PASSWORD="${DB_PASSWORD}"
# ==============================================================================
EOF

print_success "Secrets backup saved to: .secrets-backup.txt"
print_warning "DELETE este arquivo após salvar os secrets em local seguro!"

echo ""

# ==============================================================================
# SUMMARY
# ==============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║        ✅  PREPARAÇÃO CONCLUÍDA COM SUCESSO! ✅                ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

print_success "Lambda JAR built: LambdaValidaPessoa/target/ValidaPessoa-1.0.jar"
print_success "Secrets generated: infra/terraform/secrets.auto.tfvars"
print_success "AWS credentials verified"
print_success "Terraform initialized and validated"

echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo ""
echo "1. Revisar o plano de execução:"
echo "   ${BLUE}cd infra/terraform && terraform plan${NC}"
echo ""
echo "2. Aplicar a infraestrutura (se o plan estiver OK):"
echo "   ${BLUE}terraform apply${NC}"
echo ""
echo "3. Testar a API após deploy:"
echo "   ${BLUE}# URL será exibida nos outputs do Terraform${NC}"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   • Salve os secrets do arquivo .secrets-backup.txt em local seguro"
echo "   • DELETE o arquivo .secrets-backup.txt após backup"
echo "   • Configure os GitHub Secrets para CI/CD funcionar"
echo "   • Revise ANALISE_CONFIGURACAO_DEPLOY_AWS.md para detalhes"
echo ""

# ==============================================================================
# Optional: Display estimated costs
# ==============================================================================
echo "💰 ESTIMATIVA DE CUSTOS AWS:"
echo "   • Lambda: ~\$0.20/mês"
echo "   • RDS (db.t4g.micro): ~\$12.41/mês"
echo "   • NAT Gateway: ~\$32.85/mês"
echo "   • API Gateway: ~\$3.50/mês"
echo "   • Outros: ~\$1.00/mês"
echo "   ${YELLOW}TOTAL ESTIMADO: ~\$49.86/mês${NC}"
echo ""
echo "   Para reduzir custos em dev:"
echo "   • Desabilite NAT Gateway: enable_nat_gateway = false"
echo "   • Use DynamoDB ao invés de RDS"
echo ""

