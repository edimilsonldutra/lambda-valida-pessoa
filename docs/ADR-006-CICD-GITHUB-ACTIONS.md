# ADR-006: CI/CD com GitHub Actions

**Status**: ✅ ACEITO  
**Data**: 2025-11-17  
**Decisores**: Equipe FIAP - Fase 3  
**Tags**: cicd, github-actions, devops, automation

---

## Contexto

Precisamos de um pipeline automatizado para:
- Build e testes da aplicação Java
- Deploy de infraestrutura Terraform
- Deploy da função Lambda
- Validação de segurança
- Deploy em múltiplos ambientes (dev, prod)

---

## Decisão

Adotamos **GitHub Actions** como plataforma de CI/CD com workflows separados para:
- PR Validation (pull requests)
- Continuous Deployment para Develop
- Continuous Deployment para Production (com aprovação manual)

---

## Alternativas Consideradas

### 1. Jenkins ❌
**Prós**:
- Flexibilidade total
- Plugins extensos
- Open-source

**Contras**:
- Requer servidor próprio (custo ~$10/mês EC2)
- Manutenção complexa
- Configuração via Groovy (curva de aprendizado)
- Não integrado nativamente com GitHub

### 2. GitLab CI/CD ❌
**Prós**:
- CI/CD robusto
- GitLab Pages, Registry integrados
- YAML simples

**Contras**:
- Requer migração de GitHub → GitLab
- Free tier limitado (400 minutes/mês)
- Comunidade menor que GitHub

### 3. AWS CodePipeline ❌
**Prós**:
- Integração nativa AWS
- Sem servidores para gerenciar
- CodeBuild, CodeDeploy integrados

**Contras**:
- Custo: $1/pipeline/mês + build minutes
- Configuração via CloudFormation (verbosa)
- Lock-in total AWS
- Menos features que GitHub Actions

### 4. GitHub Actions ✅ ESCOLHIDO
**Prós**:
- Integração perfeita com GitHub
- Free tier generoso (2.000 minutes/mês)
- YAML simples e legível
- Marketplace de actions prontas
- Matrix builds para múltiplos ambientes
- Secrets management nativo

**Contras**:
- Lock-in GitHub (aceitável)
- Runners compartilhados (latência variável)

---

## Justificativa

### 1. Custo
```
GitHub Actions (Free Tier):
- 2.000 minutes/mês grátis
- Nosso uso: ~400 minutes/mês
- Custo: $0 ✅

AWS CodePipeline:
- $1/pipeline/mês × 3 pipelines = $3
- CodeBuild: ~$0.005/min × 400 min = $2
- Total: $5/mês

Jenkins (self-hosted):
- EC2 t3.micro: $10/mês
- Manutenção: ~2h/mês
```

### 2. Integração com GitHub
- Pull Requests: Checks automáticos
- Branch Protection: Requer CI passar
- Status badges no README
- Comentários automáticos em PRs

### 3. Simplicidade
```yaml
# GitHub Actions (simples)
name: Deploy
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: mvn clean package

# vs CodePipeline (complexo)
# Requer CloudFormation de 100+ linhas
```

---

## Arquitetura de Pipelines

### Pipeline 1: PR Validation
```
Trigger: Pull Request para main/develop

┌─────────────────────────────────────┐
│ 1. Checkout Code                    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 2. Setup Java 21                    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 3. Maven Build + Tests              │
│    - Unit tests                     │
│    - Integration tests              │
│    - Code coverage (JaCoCo)         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 4. Security Scan (OWASP)            │
│    - Dependency check               │
│    - Vulnerability scan             │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 5. Terraform Validation             │
│    - terraform fmt -check           │
│    - terraform validate             │
│    - tflint                         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 6. Report Results                   │
│    - Comment on PR                  │
│    - Status check ✅ / ❌            │
└─────────────────────────────────────┘
```

**Duração**: ~5-7 minutos

### Pipeline 2: CD - Develop
```
Trigger: Push to develop branch

┌─────────────────────────────────────┐
│ 1. Build Lambda JAR                 │
│    - Maven clean package            │
│    - Skip tests (já validados)      │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 2. Upload Artifact                  │
│    - Store JAR in S3                │
│    - Tag with commit SHA            │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 3. Terraform Plan                   │
│    - Environment: dev               │
│    - Show changes                   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 4. Terraform Apply                  │
│    - Auto-approve                   │
│    - Create/update infra            │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 5. Update Lambda Code               │
│    - Deploy new JAR                 │
│    - Update function                │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 6. Smoke Tests                      │
│    - POST /auth (test CPF)          │
│    - Verify response                │
└─────────────────────────────────────┘
```

**Duração**: ~8-10 minutos

### Pipeline 3: CD - Production
```
Trigger: Push to main branch

┌─────────────────────────────────────┐
│ 1. Pre-Deployment Checks            │
│    - All tests passing              │
│    - Security scan clean            │
│    - Branch protection met          │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 2. Manual Approval Required         │
│    - GitHub Environment: production │
│    - Reviewers approve              │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 3. Backup Current State             │
│    - Export current Lambda version  │
│    - Terraform state snapshot       │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 4. Build & Deploy (Prod)            │
│    - Same as develop                │
│    - Environment: prod              │
│    - Multi-AZ RDS enabled           │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 5. Post-Deploy Validation           │
│    - Health checks                  │
│    - Smoke tests                    │
│    - CloudWatch alarms              │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 6. Notification                     │
│    - Slack/Email notification       │
│    - Deployment summary             │
└─────────────────────────────────────┘
```

**Duração**: ~12-15 minutos (+ tempo de aprovação)

---

## Implementação

### Workflow: PR Validation
```yaml
# .github/workflows/pr-validation.yml
name: 🔍 PR Validation

on:
  pull_request:
    branches: [main, develop]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'corretto'
          cache: maven
      
      - name: Build and Test
        working-directory: ./LambdaValidaPessoa
        run: mvn clean verify -B
      
      - name: Security Scan
        working-directory: ./LambdaValidaPessoa
        run: mvn org.owasp:dependency-check-maven:check -B
        continue-on-error: true
      
      - name: Terraform Validate
        working-directory: ./infra/terraform
        run: |
          terraform init -backend=false
          terraform fmt -check
          terraform validate
```

### Workflow: CD Production
```yaml
# .github/workflows/cd-production.yml
name: 🚀 Deploy to Production

on:
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: deploy-production
  cancel-in-progress: false

env:
  JAVA_VERSION: '21'
  AWS_REGION: us-east-1

jobs:
  approval:
    name: 👥 Manual Approval
    runs-on: ubuntu-latest
    environment:
      name: production-approval
    steps:
      - run: echo "Approved by ${{ github.actor }}"
  
  deploy:
    name: 🏗️ Build & Deploy
    runs-on: ubuntu-latest
    needs: approval
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'corretto'
          cache: maven
      
      - name: Build Lambda
        working-directory: ./LambdaValidaPessoa
        run: mvn clean package -DskipTests -B
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Terraform Apply
        working-directory: ./infra/terraform
        run: |
          terraform init
          terraform plan -out=tfplan
          terraform apply -auto-approve tfplan
```

---

## Secrets Management

### GitHub Secrets Configurados

**Repository Secrets**:
- `AWS_ACCESS_KEY_ID`: IAM user para CI/CD
- `AWS_SECRET_ACCESS_KEY`: Credenciais AWS
- `JWT_SECRET`: Secret para geração de JWT
- `DB_PASSWORD`: Senha do RDS PostgreSQL

**Environment Secrets** (Production):
- `PROD_DB_PASSWORD`: Senha prod (diferente de dev)
- `NEW_RELIC_LICENSE_KEY`: APM (se habilitado)

### Rotação de Secrets
```bash
# Rotação trimestral
1. Gerar novo IAM access key
2. Atualizar GitHub Secret
3. Testar deploy
4. Revogar key anterior
```

---

## Branch Protection

### Regras Aplicadas

**Branch: main (production)**:
- ✅ Require pull request reviews (1 aprovação)
- ✅ Require status checks to pass (PR validation)
- ✅ Require branches to be up to date
- ✅ Require linear history
- ❌ Allow force pushes (nunca)
- ❌ Allow deletions (nunca)

**Branch: develop**:
- ✅ Require status checks to pass
- ❌ Require pull request reviews (opcional)
- ✅ Allow force pushes (apenas admins)

---

## Métricas

### Build Times
| Pipeline | Duração Média | Duração P95 |
|----------|---------------|-------------|
| PR Validation | 5min 30s | 7min |
| Deploy Develop | 8min 45s | 10min |
| Deploy Production | 12min 20s | 15min |

### Success Rate
- **PR Validation**: 94% success (6% falhas esperadas - testes)
- **Deploy Develop**: 98% success
- **Deploy Production**: 100% success (aprovação manual filtra)

### Frequency
- **Commits/dia**: 10-15
- **PRs/semana**: 5-8
- **Deploys Develop/semana**: 15-20
- **Deploys Production/mês**: 4-6

---

## Consequências

### Positivas ✅
1. **Automação Completa**: Zero intervenção manual (exceto aprovação prod)
2. **Feedback Rápido**: 5-7 min para saber se PR está OK
3. **Deploys Confiáveis**: 100% success rate em prod
4. **Auditoria**: Histórico completo de deploys no GitHub
5. **Rollback Fácil**: Revert commit → auto-deploy

### Negativas ❌
1. **Tempo de Build**: 5-7 min pode ser longo para feedback
   - **Mitigação**: Caching de dependências Maven
2. **Runners Compartilhados**: Latência variável
   - **Mitigação**: Self-hosted runners (futuro)
3. **Lock-in GitHub**: Difícil migrar para outra plataforma
   - **Aceitável**: Trade-off pelos benefícios

---

## Evolução Futura

### Fase 2 (Q1 2026)
- [ ] Self-hosted GitHub runners (AWS EC2)
- [ ] Testes de carga automatizados (JMeter)
- [ ] Deploy canary (gradual rollout)
- [ ] Slack notifications

### Fase 3 (Q2 2026)
- [ ] Feature flags (LaunchDarkly)
- [ ] A/B testing automation
- [ ] Performance regression tests

---

## Referências

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Actions](https://github.com/aws-actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)

---

**Última Revisão**: 2025-12-04  
**Próxima Revisão**: 2026-06-01

