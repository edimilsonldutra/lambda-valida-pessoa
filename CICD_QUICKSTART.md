# 🚀 Quick Start CI/CD

## GitHub Actions (Recomendado)

### 1. Configurar Secrets
```
Settings → Secrets → Actions → New secret
```

**Secrets obrigatórios:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `JWT_SECRET` (min 32 caracteres)
- `DB_PASSWORD`
- `ALERT_EMAIL`

**Opcional:**
- `NEW_RELIC_LICENSE_KEY`
- `SLACK_WEBHOOK_URL`

### 2. Criar Environments
```
Settings → Environments → New environment
```

Criar:
- `dev` (auto deploy)
- `staging` (manual approval)
- `prod` (manual approval)

### 3. Push código
```bash
git add .
git commit -m "feat: add CI/CD"
git push origin main
```

### 4. Ver Pipeline
```
Actions tab → Deploy Lambda Valida Pessoa
```

---

## 📁 Arquivos Criados

### GitHub Actions
- `.github/workflows/deploy.yml` - Deploy principal
- `.github/workflows/pr-validation.yml` - Validação de PR
- `.github/workflows/docker-build.yml` - Build Docker
- `.github/workflows/destroy.yml` - Destroy infra

### GitLab CI
- `.gitlab-ci.yml` - Pipeline completo

### Jenkins
- `Jenkinsfile` - Pipeline declarativo

---

## 🎯 Workflow

```
1. Push code → main
2. Trigger: deploy.yml
3. Stages:
   ✅ Build & Test
   ✅ Security Scan
   ✅ Terraform Plan
   ✅ Deploy (manual approval)
   ✅ Integration Test
   ✅ Notify
```

---

## 📚 Documentação Completa

Veja: **CICD_DOCUMENTATION.md**

---

**Pronto para começar!** Push seu código e veja a mágica acontecer! 🎉

