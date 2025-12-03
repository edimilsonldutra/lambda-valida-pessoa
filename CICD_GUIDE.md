# 🚀 Guia Completo de CI/CD - GitHub Actions

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Estratégia de Branches](#estratégia-de-branches)
- [Workflows](#workflows)
- [Configuração Inicial](#configuração-inicial)
- [Secrets Necessários](#secrets-necessários)
- [Ambientes](#ambientes)
- [Processos](#processos)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Este projeto implementa um pipeline completo de CI/CD seguindo as melhores práticas de DevOps e GitFlow, garantindo:

- ✅ **Nenhum commit direto na main** - Toda alteração via Pull Request
- ✅ **Ambiente de desenvolvimento isolado** - Branch `develop` para integração
- ✅ **Ambiente de produção protegido** - Branch `main` com aprovações obrigatórias
- ✅ **Testes automatizados** - Em cada PR e deploy
- ✅ **Quality Gates** - Análise de código, segurança e cobertura
- ✅ **Deploy automatizado** - Blue/Green deployment em produção
- ✅ **Rollback automático** - Em caso de falhas

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                     Feature Development                      │
├─────────────────────────────────────────────────────────────┤
│  feature/*  →  PR  →  develop  →  PR  →  main  →  production│
│  bugfix/*   →  PR  →  develop  →  PR  →  main  →  production│
│  hotfix/*   →  PR  →────────────→  main  →  production      │
└─────────────────────────────────────────────────────────────┘

CI/CD Pipeline Flow:
┌──────────────┐
│ Pull Request │ → CI (Build, Test, Quality, Security)
└──────────────┘
       ↓
┌──────────────┐
│   develop    │ → CD Development (Auto Deploy)
└──────────────┘
       ↓
┌──────────────┐
│     main     │ → CD Production (Manual Approval + Blue/Green)
└──────────────┘
```

---

## 🌲 Estratégia de Branches

### Branch Protection Rules

#### 🔒 Branch: `main` (Produção)

**Regras Obrigatórias:**
- ❌ Sem commits diretos
- ✅ Require pull request antes de merge
- ✅ Require 2 aprovações de reviewers
- ✅ Dismiss stale pull request approvals quando novos commits são pushed
- ✅ Require review de code owners
- ✅ Require status checks antes de merge:
  - `CI Pipeline Success`
  - `Build & Unit Tests`
  - `Security Scan`
  - `Terraform Validation`
- ✅ Require branches estejam atualizadas antes de merge
- ✅ Require conversation resolution antes de merge
- ✅ Require signed commits (recomendado)
- ✅ Include administrators (regras aplicam a todos)
- ❌ Allow force pushes
- ❌ Allow deletions

#### 🔧 Branch: `develop` (Desenvolvimento)

**Regras Obrigatórias:**
- ❌ Sem commits diretos
- ✅ Require pull request antes de merge
- ✅ Require 1 aprovação de reviewer
- ✅ Require status checks antes de merge:
  - `Build & Unit Tests`
  - `Code Quality Analysis`
- ✅ Require branches estejam atualizadas antes de merge
- ❌ Allow force pushes
- ❌ Allow deletions

### Convenção de Nomes de Branches

```bash
feature/ISSUE-XXX-short-description    # Novas funcionalidades
bugfix/ISSUE-XXX-short-description     # Correções de bugs
hotfix/ISSUE-XXX-short-description     # Correções urgentes em produção
release/vX.Y.Z                          # Preparação de release
```

**Exemplos:**
```bash
feature/FIAP-123-add-jwt-validation
bugfix/FIAP-456-fix-cpf-validation
hotfix/FIAP-789-critical-security-fix
release/v1.2.0
```

---

## ⚙️ Workflows

### 1. 🔍 CI - Continuous Integration (`ci.yml`)

**Trigger:**
- Pull Requests para `develop` ou `main`
- Push em `develop`, `feature/*`, `bugfix/*`, `hotfix/*`

**Jobs:**
1. **Code Quality & Security**
   - Checkstyle
   - OWASP Dependency Check
   - SonarCloud Scan

2. **Build & Unit Tests**
   - Maven build
   - Testes unitários
   - Cobertura de código (Jacoco)
   - Upload para Codecov

3. **Integration Tests**
   - Testes com LocalStack
   - Validação de integração AWS

4. **Docker Build Validation**
   - Build da imagem Docker
   - Trivy security scan

5. **Terraform Validation**
   - Terraform fmt check
   - Terraform validate
   - TFLint

### 2. 🚀 CD Development (`cd-develop.yml`)

**Trigger:**
- Push na branch `develop`
- Manual dispatch

**Jobs:**
1. **Build & Deploy Lambda**
   - Build do JAR
   - Upload para S3
   - Update Lambda function
   - Tag deployment

2. **Deploy Infrastructure**
   - Terraform apply para ambiente dev

3. **Smoke Tests**
   - Testes básicos de sanidade
   - Validação CloudWatch logs

4. **Notification**
   - Slack notification

### 3. 🚀 CD Production (`cd-production.yml`)

**Trigger:**
- Push na branch `main`
- Release published
- Manual dispatch

**Jobs:**
1. **Pre-deployment Checks**
   - Testes completos
   - Security scan
   - Coverage check

2. **Manual Approval**
   - Aprovação obrigatória via GitHub Environments

3. **Build & Deploy**
   - Backup da versão atual
   - Deploy com estratégia Blue/Green:
     - 10% tráfego (canary)
     - Monitoramento 5 minutos
     - 100% tráfego se OK
     - Rollback automático se falhar

4. **Deploy Infrastructure**
   - Terraform apply para produção

5. **Production Tests**
   - Health checks
   - Smoke tests

6. **Create Release Tag**
   - Tag semântico automático

7. **Notifications**
   - Slack e Email

### 4. 🔍 PR Validation (`pr-validation.yml`)

**Trigger:**
- Pull Request opened/synchronized/reopened

**Jobs:**
1. **PR Validation**
   - Validação título (Conventional Commits)
   - Validação descrição
   - Validação naming da branch
   - Check tamanho do PR

2. **Build & Test**
   - Build e testes
   - Coverage report no PR

3. **Code Quality**
   - Checkstyle, PMD, SpotBugs

4. **Security Scan**
   - OWASP, Snyk

5. **Check Conflicts**
   - Detecção de conflitos

6. **Auto-label**
   - Labels automáticos baseados em arquivos

7. **PR Comment**
   - Comentário com status dos checks

### 5. 🔄 Sync Develop to Main (`sync-develop-to-main.yml`)

**Trigger:**
- Schedule (toda segunda às 10h UTC)
- Manual dispatch

**Jobs:**
- Cria PR automático para sincronizar `develop` → `main`
- Notificação Slack

---

## 🔧 Configuração Inicial

### 1. Configurar Branch Protection

**No GitHub:**
1. Vá em `Settings` → `Branches`
2. Adicione regra para `main`:
   ```
   Branch name pattern: main
   [x] Require a pull request before merging
       [x] Require approvals: 2
       [x] Dismiss stale pull request approvals when new commits are pushed
       [x] Require review from Code Owners
   [x] Require status checks to pass before merging
       [x] Require branches to be up to date before merging
       Status checks: CI Pipeline Success, Build & Unit Tests, Security Scan
   [x] Require conversation resolution before merging
   [x] Include administrators
   [ ] Allow force pushes
   [ ] Allow deletions
   ```

3. Adicione regra para `develop`:
   ```
   Branch name pattern: develop
   [x] Require a pull request before merging
       [x] Require approvals: 1
   [x] Require status checks to pass before merging
       Status checks: Build & Unit Tests, Code Quality Analysis
   [ ] Allow force pushes
   [ ] Allow deletions
   ```

### 2. Criar Environments

**No GitHub:**
1. Vá em `Settings` → `Environments`
2. Crie os ambientes:

**Environment: `development`**
```yaml
Environment protection rules:
- No protection rules (auto deploy)
Environment secrets:
- AWS_ACCESS_KEY_ID_DEV
- AWS_SECRET_ACCESS_KEY_DEV
- S3_DEPLOYMENT_BUCKET_DEV
```

**Environment: `production-approval`**
```yaml
Environment protection rules:
- Required reviewers: [time lead, tech lead]
- Wait timer: 0 minutes
```

**Environment: `production`**
```yaml
Environment protection rules:
- Required reviewers: [time lead, tech lead, product owner]
- Wait timer: 5 minutes
Environment secrets:
- AWS_ACCESS_KEY_ID_PROD
- AWS_SECRET_ACCESS_KEY_PROD
- S3_DEPLOYMENT_BUCKET_PROD
```

**Environment: `development-infra`**
```yaml
Environment protection rules:
- No protection rules
```

**Environment: `production-infra`**
```yaml
Environment protection rules:
- Required reviewers: [infra lead]
```

### 3. Configurar CODEOWNERS

Crie `.github/CODEOWNERS`:
```
# Default owners
* @team-lead @tech-lead

# Infrastructure
/infra/ @infra-team @tech-lead
*.tf @infra-team

# CI/CD
/.github/ @devops-team @tech-lead

# Lambda code
/LambdaValidaPessoa/ @backend-team @tech-lead

# Documentation
*.md @product-owner @tech-lead
```

---

## 🔐 Secrets Necessários

### Repository Secrets

Configure em `Settings` → `Secrets and variables` → `Actions`:

#### AWS Credentials - Development
```bash
AWS_ACCESS_KEY_ID_DEV
AWS_SECRET_ACCESS_KEY_DEV
S3_DEPLOYMENT_BUCKET_DEV=lambda-deploy-dev-bucket
```

#### AWS Credentials - Production
```bash
AWS_ACCESS_KEY_ID_PROD
AWS_SECRET_ACCESS_KEY_PROD
S3_DEPLOYMENT_BUCKET_PROD=lambda-deploy-prod-bucket
```

#### Terraform Backend
```bash
TERRAFORM_STATE_BUCKET=terraform-state-lambda-valida-pessoa
```

#### Code Quality & Security
```bash
SONAR_TOKEN=<seu-token-sonarcloud>
SONAR_ORGANIZATION=<sua-org-sonarcloud>
SNYK_TOKEN=<seu-token-snyk>
```

#### Notifications
```bash
SLACK_WEBHOOK_URL=<webhook-url-slack>
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=<email>
SMTP_PASSWORD=<senha-app>
ALERT_EMAIL=team@example.com
```

### Como Obter os Secrets

#### AWS Credentials
```bash
# Criar usuário IAM para CI/CD
aws iam create-user --user-name github-actions-dev
aws iam create-user --user-name github-actions-prod

# Criar access keys
aws iam create-access-key --user-name github-actions-dev
aws iam create-access-key --user-name github-actions-prod

# Attach policies necessárias
aws iam attach-user-policy \
  --user-name github-actions-dev \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

#### SonarCloud Token
1. Acesse https://sonarcloud.io
2. My Account → Security
3. Generate Token

#### Snyk Token
1. Acesse https://snyk.io
2. Account Settings → API Token
3. Copy token

#### Slack Webhook
1. Acesse Slack App → Incoming Webhooks
2. Adicione ao canal desejado
3. Copy Webhook URL

---

## 🌍 Ambientes

### Development
- **Branch:** `develop`
- **Deploy:** Automático a cada push
- **URL:** `https://api-dev.example.com`
- **Aprovação:** Não requerida
- **Rollback:** Manual

### Production
- **Branch:** `main`
- **Deploy:** Manual approval + Blue/Green
- **URL:** `https://api.example.com`
- **Aprovação:** 2-3 reviewers
- **Rollback:** Automático em falhas

---

## 📋 Processos

### Criar Nova Feature

```bash
# 1. Atualizar develop
git checkout develop
git pull origin develop

# 2. Criar branch feature
git checkout -b feature/FIAP-123-add-new-feature

# 3. Desenvolver e commitar
git add .
git commit -m "feat: add new feature to validate XYZ"

# 4. Push para repositório
git push origin feature/FIAP-123-add-new-feature

# 5. Criar Pull Request no GitHub
# - Base: develop
# - Compare: feature/FIAP-123-add-new-feature
# - Preencher template de PR
# - Aguardar CI passar
# - Solicitar review

# 6. Após aprovação, merge via GitHub
# - Squash and merge (recomendado)
# - Delete branch após merge
```

### Correção de Bug

```bash
# Mesmo processo da feature, mas com prefixo bugfix/
git checkout develop
git checkout -b bugfix/FIAP-456-fix-validation-error
# ... desenvolver ...
git push origin bugfix/FIAP-456-fix-validation-error
# Criar PR para develop
```

### Hotfix em Produção

```bash
# Para correções urgentes em produção
git checkout main
git pull origin main
git checkout -b hotfix/FIAP-789-critical-fix

# ... desenvolver e testar ...
git push origin hotfix/FIAP-789-critical-fix

# Criar PR para main (fast-track)
# Após deploy, fazer PR do hotfix para develop também
```

### Release para Produção

```bash
# Opção 1: PR Manual
# 1. Criar PR de develop para main
# 2. Aguardar aprovações (2-3 reviewers)
# 3. Merge → Trigger CD Production

# Opção 2: Sync Automático (Recomendado)
# - Workflow automático toda segunda
# - Cria PR develop → main
# - Team review e aprova
# - Merge → Deploy production
```

---

## 🚨 Troubleshooting

### CI Falhando

**Problema:** Testes unitários falhando
```bash
# Rodar testes localmente
cd LambdaValidaPessoa
mvn clean test

# Ver logs detalhados
mvn test -X
```

**Problema:** Terraform validation falhando
```bash
# Validar localmente
cd infra/terraform
terraform fmt -check -recursive
terraform validate
```

**Problema:** Docker build falhando
```bash
# Build local
docker build -t lambda-valida-pessoa:test .

# Debug
docker build --no-cache --progress=plain -t lambda-valida-pessoa:test .
```

### CD Falhando

**Problema:** Deploy para Lambda falhando
```bash
# Verificar se função existe
aws lambda get-function --function-name lambda-valida-pessoa-dev

# Verificar logs
aws logs tail /aws/lambda/lambda-valida-pessoa-dev --follow
```

**Problema:** Terraform apply falhando
```bash
# Ver state atual
terraform show

# Plan para debug
terraform plan -out=debug.tfplan
terraform show debug.tfplan
```

### Rollback Manual

```bash
# Production rollback
FUNCTION_NAME="lambda-valida-pessoa-prod"

# Listar versões
aws lambda list-versions-by-function --function-name $FUNCTION_NAME

# Rollback para versão anterior
aws lambda update-alias \
  --function-name $FUNCTION_NAME \
  --name production \
  --function-version <VERSION_ANTERIOR>
```

---

## 📊 Métricas e Monitoramento

### GitHub Actions Insights
- `Actions` → Ver tempo de execução
- `Actions` → `Caching` → Ver cache hits
- `Actions` → `Usage` → Ver minutos consumidos

### Métricas Importantes
- ⏱️ **Pipeline Duration:** < 10 minutos
- ✅ **Success Rate:** > 95%
- 🔄 **Deployment Frequency:** Diário (dev), Semanal (prod)
- 🚀 **Lead Time:** < 1 dia (dev), < 3 dias (prod)
- 🔙 **Rollback Rate:** < 5%

---

## 📚 Referências

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## 🤝 Suporte

Para questões sobre CI/CD:
- 📧 Email: devops@example.com
- 💬 Slack: #devops-support
- 📝 Issues: Use template de bug/feature

---

**Última atualização:** 2025-12-03  
**Versão:** 1.0.0

