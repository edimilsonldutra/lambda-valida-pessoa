# 🚀 Quick Start - CI/CD Pipeline

## ⚡ Setup em 5 Minutos

### 1. Execute o Script de Configuração

**Windows:**
```bash
.\scripts\setup-cicd.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/setup-cicd.sh
./scripts/setup-cicd.sh
```

### 2. Configure os Secrets Essenciais

No GitHub: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

**Mínimo necessário para começar:**
```
AWS_ACCESS_KEY_ID_DEV=<sua-key-dev>
AWS_SECRET_ACCESS_KEY_DEV=<sua-secret-dev>
S3_DEPLOYMENT_BUCKET_DEV=lambda-deploy-dev-bucket
```

### 3. Teste o Pipeline

```bash
# Criar feature branch
git checkout -b feature/test-pipeline

# Fazer um commit
echo "test" > test.txt
git add test.txt
git commit -m "test: validar pipeline CI/CD"

# Push
git push origin feature/test-pipeline
```

### 4. Criar Pull Request

1. Vá no GitHub
2. Você verá um banner "Compare & pull request" - clique nele
3. Base: `develop`
4. Preencha o template
5. Create pull request

**O que vai acontecer:**
- ✅ CI pipeline será executado automaticamente
- ✅ Testes serão executados
- ✅ Build será feito
- ✅ Análise de qualidade será feita
- ✅ Comentário automático com status será adicionado ao PR

### 5. Após Aprovação, Merge!

- Após merge em `develop` → Deploy automático para ambiente dev
- Para produção: criar PR de `develop` → `main`

---

## 📋 Workflow Diário

### Desenvolver Nova Feature

```bash
# 1. Atualizar develop
git checkout develop
git pull origin develop

# 2. Criar branch
git checkout -b feature/ISSUE-123-descricao-curta

# 3. Desenvolver...
# ... código ...

# 4. Commit (use conventional commits!)
git add .
git commit -m "feat: adiciona validação de email"

# 5. Push
git push origin feature/ISSUE-123-descricao-curta

# 6. Criar PR no GitHub (develop ← feature)
```

### Conventional Commits (importante!)

Use esses prefixos:
- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Apenas documentação
- `style:` - Formatação (sem mudança de código)
- `refactor:` - Refatoração
- `perf:` - Melhoria de performance
- `test:` - Adicionar testes
- `build:` - Build system
- `ci:` - CI/CD
- `chore:` - Tarefas gerais

**Exemplos:**
```bash
git commit -m "feat: adiciona validação de CPF internacional"
git commit -m "fix: corrige erro na validação de dígitos verificadores"
git commit -m "docs: atualiza README com exemplos de uso"
git commit -m "refactor: simplifica lógica de cálculo de CPF"
```

---

## 🔀 Branch Strategy

```
main (produção)
  ↑
  PR (requer 2 aprovações)
  ↑
develop (desenvolvimento)
  ↑
  PR (requer 1 aprovação)
  ↑
feature/bugfix/hotfix branches
```

**Regras:**
- ❌ Nunca commitar direto em `main` ou `develop`
- ✅ Sempre criar PR
- ✅ Aguardar CI passar
- ✅ Aguardar aprovações
- ✅ Resolver conflitos antes do merge

---

## 🎯 Checklist Antes de Criar PR

- [ ] Código compila sem erros
- [ ] Testes unitários passam localmente (`mvn test`)
- [ ] Código está formatado (`mvn checkstyle:check`)
- [ ] Commit messages seguem Conventional Commits
- [ ] Branch name segue padrão (`feature/`, `bugfix/`, `hotfix/`)
- [ ] PR tem descrição clara
- [ ] PR referencia issue(s) relacionada(s)

---

## 🐛 Troubleshooting Rápido

### CI falhando?

```bash
# Rodar localmente os mesmos checks
cd LambdaValidaPessoa

# Build
mvn clean compile

# Testes
mvn test

# Checkstyle
mvn checkstyle:check

# Package completo
mvn clean package
```

### Conflitos no PR?

```bash
# Atualizar sua branch
git checkout feature/sua-branch
git fetch origin
git rebase origin/develop

# Resolver conflitos se houver
# ... edite os arquivos ...
git add .
git rebase --continue

# Force push (ok para feature branches)
git push --force-with-lease origin feature/sua-branch
```

### PR muito grande?

**Dica:** Quebre em PRs menores!
- Cada PR deve ter uma responsabilidade única
- Ideal: < 400 linhas alteradas
- Máximo recomendado: 1000 linhas

---

## 📊 Status Checks

Seu PR precisa passar nesses checks antes do merge:

### Para develop:
- ✅ Build & Unit Tests
- ✅ Code Quality Analysis

### Para main:
- ✅ CI Pipeline Success
- ✅ Build & Unit Tests
- ✅ Security Scan
- ✅ Terraform Validation

---

## 🚀 Deploy Flow

### Development (automático)
```
Push to develop → CI passa → Deploy automático → Notificação Slack
```

### Production (manual)
```
PR develop→main → Aprovações → CI passa → Aprovação manual → 
  → Blue/Green deploy (10% canary) → Monitoramento → 
  → 100% tráfego → Notificação
```

---

## 🆘 Precisa de Ajuda?

1. **Leia primeiro:** `CICD_GUIDE.md` (guia completo)
2. **Problemas comuns:** Seção Troubleshooting no guia
3. **Pergunte no Slack:** #devops-support
4. **Crie uma issue:** Use template de bug

---

## 📚 Links Úteis

- [Guia Completo](CICD_GUIDE.md)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

---

**Pronto para começar?** 🎉

```bash
git checkout develop
git pull origin develop
git checkout -b feature/sua-primeira-feature
# ... code code code ...
git commit -m "feat: minha primeira feature"
git push origin feature/sua-primeira-feature
# Criar PR no GitHub!
```

