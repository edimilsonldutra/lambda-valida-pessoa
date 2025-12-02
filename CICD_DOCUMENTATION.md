# 🔄 CI/CD - Lambda Valida Pessoa
**Plataformas:** GitHub Actions, GitLab CI, Jenkins
**Versão:** 1.0  
**Criado em:** 2025-12-02  

---

- [AWS Lambda CI/CD](https://docs.aws.amazon.com/lambda/latest/dg/cicd.html)
- [Terraform in CI/CD](https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform)
- [Jenkins Pipeline Docs](https://www.jenkins.io/doc/book/pipeline/)
- [GitLab CI/CD Docs](https://docs.gitlab.com/ee/ci/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

## 📖 Referências

---

6. **Treinar** equipe no uso
5. **Documentar** processo específico do time
4. **Configurar notificações** (Slack, Email)
3. **Testar pipeline** com dispatch manual
2. **Configurar secrets/variables**
1. **Escolher plataforma** (GitHub Actions recomendado)

## 🎯 Próximos Passos

---

- [ ] Testar build
- [ ] Pipeline job criado
- [ ] Tools configuradas (JDK, Maven)
- [ ] Credentials configuradas
- [ ] Plugins instalados
- [ ] Jenkins instalado
### Jenkins

- [ ] Testar pipeline
- [ ] Environments configurados
- [ ] Runners disponíveis com tag `docker`
- [ ] Variables configuradas
- [ ] Repositório no GitLab
### GitLab CI

- [ ] Testar workflow com dispatch manual
- [ ] Branch protection rules
- [ ] Environments criados (dev, staging, prod)
- [ ] Secrets configurados
- [ ] Repositório no GitHub
### GitHub Actions

## ✅ Checklist de Setup

---

```
          --routing-config AdditionalVersionWeights={"2"=1.0}
          --name live \
          --function-name $FUNCTION_NAME \
        aws lambda update-alias \
      run: |
    - name: Deploy 100% if healthy
    
      run: sleep 600
    - name: Wait and monitor
    
          --routing-config AdditionalVersionWeights={"2"=0.1}
          --name live \
          --function-name $FUNCTION_NAME \
        aws lambda update-alias \
      run: |
    - name: Deploy 10% traffic
  steps:
canary_deploy:
```yaml

### Canary Deployment

```
      run: terraform apply -auto-approve
        AWS_REGION: ${{ matrix.region }}
      env:
    - name: Deploy to ${{ matrix.region }}
  steps:
      region: [us-east-1, eu-west-1, ap-southeast-1]
    matrix:
  strategy:
deploy_multi_region:
```yaml

### Multi-Region Deploy

## 📚 Exemplos Avançados

---

```
          -var="lambda_version=$PREVIOUS_VERSION"
        terraform -chdir=infra/terraform apply \
      run: |
    - name: Rollback to previous version
  steps:
  when: manual
  name: Rollback
rollback:
```yaml

### Adicionar Deploy Rollback

```
        newman run tests/integration.postman_collection.json
        npm install newman
      run: |
    - name: Run integration tests
  steps:
  needs: deploy
  name: Integration Tests
integration_test:
```yaml

### Adicionar Teste de Integração

```
    - qa-branch
  only:
    name: qa
  environment:
  stage: deploy
deploy_qa:
```yaml
**GitLab CI:**

```
  # ... resto da configuração
  environment: qa
  name: Deploy to QA
deploy_qa:
```yaml
**GitHub Actions:**

### Adicionar Ambiente Novo

## 🎨 Customização

---

- Usar artifacts para passar dados entre jobs
- Paralelizar jobs independentes
- Usar cache de layers Docker
- Usar cache de dependências Maven
**Otimizações:**

### Pipeline lento

```
    password: ${{ secrets.DOCKERHUB_TOKEN }}
    username: ${{ secrets.DOCKERHUB_USERNAME }}
  with:
  uses: docker/login-action@v3
- name: Login to Docker Hub
```yaml
**Solução GitHub Actions:**

### Erro: "Docker rate limit"

- Verificar path do JAR está correto
- Verificar artifacts foram salvos
- Verificar stage de build completou
**Solução:**

### Erro: "JAR file not found"

- Usar `-backend=false` para validação
- Verificar permissões no S3
- Verificar bucket S3 existe
**Solução:**

### Erro: "Terraform backend initialization failed"

- Verificar permissões IAM
- Validar Access Key não expirou
- Verificar secrets configurados
**Solução:**

### Erro: "AWS credentials not found"

## 🚨 Troubleshooting

---

- Artifacts
- Build → Console Output
**Logs:**

- Blue Ocean UI (recomendado)
- Dashboard principal
**Ver status:**

### Jenkins

- Download de artifacts
- Pipeline → Job → Ver log
**Logs:**

- Badge: Settings → CI/CD → Pipeline status
- CI/CD → Pipelines
**Ver status:**

### GitLab CI

- Slack (se configurado)
- Email automático em falhas
**Notificações:**

- Download de artifacts
- Clique no workflow → Job → Step
**Logs:**

- Badge de status: `[![Deploy](https://github.com/user/repo/workflows/Deploy/badge.svg)](https://github.com/user/repo/actions)`
- Actions tab no repositório
**Ver status:**

### GitHub Actions

## 📈 Monitoramento de Pipeline

---

```
   → Deploy direto para PROD
4. Merge + Tag

   → Validações automáticas
3. PR para main

2. Fix e test

   git checkout -b hotfix/bug-critico main
1. Criar hotfix branch de main
```

### Hotfix Flow

```
    → Deploy manual para PROD
    git push origin v1.0.0
    git tag -a v1.0.0 -m "Release 1.0.0"
10. Tag de release

9. Validar em STAGING

   → Deploy manual para STAGING
   → Triggers: deploy.yml
8. Merge develop → main

7. Testar em DEV

   → Deploy automático para DEV
   → Triggers: deploy.yml
6. Merge para develop

5. Code Review + Aprovação

   → Validações automáticas
   → Triggers: pr-validation.yml
4. Criar Pull Request

   git push origin feature/nova-funcionalidade
   git commit -m "feat: nova funcionalidade"
3. Commit e push

   mvn test
2. Desenvolver e testar localmente

   git checkout -b feature/nova-funcionalidade
1. Criar feature branch
```

### Development Flow

## 🎯 Fluxo de Trabalho Recomendado

---

   - Secrets por ambiente
   - Dev, Staging, Prod separados
5. ✅ **Ambientes isolados**

   - Review manual para prod
   - Sempre executar plan
4. ✅ **Terraform Plan antes de Apply**

   - Proteção de branches
   - Staging e Prod requerem aprovação
3. ✅ **Aprovações manuais**

   - Executado em todos os PRs
   - Trivy para vulnerabilidades
2. ✅ **Scan de segurança**

   - Masked em logs
   - Todos os secrets via variáveis de ambiente
1. ✅ **Secrets nunca em código**

### Boas Práticas Implementadas

## 🔐 Segurança

---

| **Recomendado para** | Projetos GitHub | Projetos GitLab | Enterprise |
| **Docker** | Nativo | Nativo | Plugin |
| **Aprovações** | Nativo | Nativo | Input step |
| **Ambientes** | Nativo | Nativo | Plugin |
| **Segredos** | Criptografados | Criptografados | Credentials |
| **UI** | Excelente | Muito boa | Básica |
| **Custo** | 2000 min/mês grátis | Runners próprios | Self-hosted |
| **Setup** | Fácil | Médio | Complexo |
|---------|---------------|-----------|---------|
| Aspecto | GitHub Actions | GitLab CI | Jenkins |

## 📊 Comparação de Plataformas

---

- `AUTO_APPROVE` - Auto-aprovar deploy (checkbox)
- `SKIP_TESTS` - Pular testes (checkbox)
- `ENVIRONMENT` - Escolher ambiente (dev/staging/prod)
O Jenkinsfile já inclui parâmetros:

#### 6. Parâmetros

4. Script Path: `Jenkinsfile`
3. SCM: Git
2. Pipeline script from SCM
1. New Item → Pipeline

#### 5. Pipeline Job

- `AWS_REGION` = `us-east-1`
- `SLACK_WEBHOOK_URL` = `https://hooks.slack.com/...` (opcional)
- `ALERT_EMAIL` = `devops@empresa.com`

Configure em **Manage Jenkins → Configure System → Global properties**:

#### 4. Environment Variables

| Maven | `Maven-3.9` | Maven 3.9 |
| JDK | `JDK-21` | Java 21 |
|------|------|---------|
| Tool | Name | Version |

Configure em **Manage Jenkins → Tools**:

#### 3. Tools

| `new-relic-key` | Secret text | New Relic License Key |
| `db-password` | Secret text | DB Password |
| `jwt-secret` | Secret text | JWT Secret |
| `aws-credentials` | AWS Credentials | Access Key + Secret Key |
|----|------|-------------|
| ID | Type | Description |

Configure em **Manage Jenkins → Credentials**:

#### 2. Credentials

- JUnit Plugin
- Email Extension
- Docker Pipeline
- AWS Steps Plugin
- Pipeline
Instale:

#### 1. Plugins Necessários

### 📝 Configuração

## 🔧 Jenkins

---

- **tags** → deploy_prod (manual)
- **main branch** → deploy_staging (manual)
- **develop branch** → deploy_dev (automático)

#### 4. Ambientes

6. **notify** - Notificações
5. **deploy** - Deploy (dev automático, staging/prod manual)
4. **plan** - Terraform plan
3. **security** - Scan de segurança
2. **test** - Executar testes
1. **build** - Compilar aplicação

#### 3. Pipeline Stages

- Tag: `docker`
- Docker executor
Certifique-se de ter GitLab Runners configurados com:

#### 2. Runners

| `SLACK_WEBHOOK_URL` | Webhook (opcional) | ❌ | ✅ |
| `ALERT_EMAIL` | Email | ❌ | ❌ |
| `NEW_RELIC_LICENSE_KEY` | License Key | ✅ | ✅ |
| `DB_PASSWORD` | Senha DB | ✅ | ✅ |
| `JWT_SECRET` | Secret JWT | ✅ | ✅ |
| `AWS_SECRET_ACCESS_KEY` | Sua Secret Key | ✅ | ✅ |
| `AWS_ACCESS_KEY_ID` | Sua Access Key | ✅ | ✅ |
|----------|-------|-----------|--------|
| Variable | Value | Protected | Masked |

Configure em **Settings → CI/CD → Variables**:

#### 1. Variables

### 📝 Configuração

## 🦊 GitLab CI/CD

---

```
  Confirm: destroy
  Environment: dev
Actions → Destroy Infrastructure → Run workflow
```
**Uso:**

- Dispatch manual ONLY
**Trigger:**

##### D. Destroy (`destroy.yml`)

```
docker pull ghcr.io/seu-usuario/lambda-valida-pessoa:latest
```bash
**Como usar a imagem:**

- Publica imagem em GitHub Container Registry (ghcr.io)
**Resultado:**

- Dispatch manual
- Tags `v*`
- Push para `main`
**Trigger:**

##### C. Docker Build (`docker-build.yml`)

- ✅ Security scan
- ✅ Validação Terraform
- ✅ Análise estática (PMD)
- ✅ Verificação de formatação
- ✅ Build e testes
**Validações:**

- Pull Request para `main` ou `develop`
**Trigger:**

##### B. PR Validation (`pr-validation.yml`)

```
Actions → Deploy Lambda Valida Pessoa → Run workflow
# Ou manualmente via GitHub UI:

git push origin main
# Automático ao fazer push
```bash
**Como usar:**

5. **Notify** - Notifica Slack (opcional)
4. **Deploy** - Aplica infraestrutura (só em main)
3. **Terraform Plan** - Planeja infraestrutura
2. **Security Scan** - Scan de vulnerabilidades com Trivy
1. **Build and Test** - Compila e testa Java
**Stages:**

- Dispatch manual
- Pull Request para `main`
- Push para `main` ou `develop`
**Trigger:**

##### A. Deploy Principal (`deploy.yml`)

#### 3. Workflows Disponíveis

- **prod** - Aprovação manual + proteções
- **staging** - Aprovação manual
- **dev** - Deploy automático

**Settings → Environments → New environment**
Configure environments para aprovação manual:

#### 2. Environments

| `SLACK_WEBHOOK_URL` | Webhook Slack (opcional) | `https://hooks.slack.com/...` |
| `ALERT_EMAIL` | Email para alertas | `devops@empresa.com` |
| `NEW_RELIC_LICENSE_KEY` | License Key New Relic (opcional) | `eu01xx...` |
| `DB_PASSWORD` | Senha do PostgreSQL | `SenhaForte123!` |
| `JWT_SECRET` | Secret para JWT (min 32 chars) | `sua-chave-secreta-32-chars` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `wJalrXUt...` |
| `AWS_ACCESS_KEY_ID` | AWS Access Key | `AKIAIOSFODNN7EXAMPLE` |
|--------|-----------|---------|
| Secret | Descrição | Exemplo |

**Settings → Secrets and variables → Actions → New repository secret**
Configure os seguintes secrets no GitHub:

#### 1. Secrets Necessários

### 📝 Configuração

## 🚀 GitHub Actions (Recomendado)

---

```
Jenkinsfile             # Pipeline Jenkins declarativo
```
### Jenkins

```
.gitlab-ci.yml          # Pipeline completo GitLab
```
### GitLab CI

```
└── destroy.yml          # Destruição de infraestrutura (manual)
├── docker-build.yml     # Build e publicação de imagem Docker
├── pr-validation.yml    # Validação de Pull Requests
├── deploy.yml           # Pipeline principal de deploy
.github/workflows/
```
### GitHub Actions

## 🎯 Arquivos CI/CD Criados

---

- ✅ **Jenkins**
- ✅ **GitLab CI/CD**
- ✅ **GitHub Actions** (Recomendado)
Pipeline completo de CI/CD para deploy automatizado da Lambda Function na AWS com suporte para:

## 📋 Visão Geral


