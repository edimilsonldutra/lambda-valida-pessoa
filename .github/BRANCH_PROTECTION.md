# 🔒 Branch Protection Configuration

Este arquivo documenta as configurações de proteção de branches que devem ser aplicadas no GitHub.

## 📋 Como Aplicar

### Via GitHub Web UI
1. Vá em `Settings` → `Branches`
2. Click em `Add rule` ou edite regra existente
3. Configure conforme abaixo

### Via GitHub CLI
```bash
# Instalar GitHub CLI: https://cli.github.com/
gh auth login

# Aplicar configurações
gh api repos/:owner/:repo/branches/main/protection -X PUT --input branch-protection-main.json
gh api repos/:owner/:repo/branches/develop/protection -X PUT --input branch-protection-develop.json
```

---

## 🔒 Branch: `main` (Production)

### Configuration JSON
```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "CI Pipeline Success",
      "Build & Unit Tests",
      "Security Scan",
      "Terraform Validation"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {},
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 2,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": false
}
```

### Checklist Web UI

- [x] **Require a pull request before merging**
  - [x] Require approvals: **2**
  - [x] Dismiss stale pull request approvals when new commits are pushed
  - [x] Require review from Code Owners
  - [ ] Restrict who can dismiss pull request reviews

- [x] **Require status checks to pass before merging**
  - [x] Require branches to be up to date before merging
  - Status checks that are required:
    - [x] CI Pipeline Success
    - [x] Build & Unit Tests
    - [x] Security Scan
    - [x] Terraform Validation

- [x] **Require conversation resolution before merging**

- [x] **Require signed commits** (opcional mas recomendado)

- [x] **Require linear history** (opcional)

- [x] **Include administrators**

- [ ] **Allow force pushes** (DESABILITADO)

- [ ] **Allow deletions** (DESABILITADO)

---

## 🔧 Branch: `develop` (Development)

### Configuration JSON
```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Build & Unit Tests",
      "Code Quality Analysis"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {},
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": false
}
```

### Checklist Web UI

- [x] **Require a pull request before merging**
  - [x] Require approvals: **1**
  - [x] Dismiss stale pull request approvals when new commits are pushed
  - [ ] Require review from Code Owners

- [x] **Require status checks to pass before merging**
  - [x] Require branches to be up to date before merging
  - Status checks that are required:
    - [x] Build & Unit Tests
    - [x] Code Quality Analysis

- [x] **Require conversation resolution before merging**

- [ ] **Include administrators** (opcional para develop)

- [ ] **Allow force pushes** (DESABILITADO)

- [ ] **Allow deletions** (DESABILITADO)

---

## 🏷️ Branch Patterns (Wildcards)

Para proteger múltiplas branches com padrões:

### `release/*`
```
Pattern: release/*
- Require pull request: Yes (1 approval)
- Require status checks: Yes
- Allow deletions: No
```

### `hotfix/*`
```
Pattern: hotfix/*
- Require pull request: Yes (1 approval)
- Require status checks: Yes (fast-track allowed)
- Allow deletions: Yes (após merge)
```

---

## 🚀 Script de Aplicação Automática

### apply-branch-protection.sh

```bash
#!/bin/bash

OWNER="your-github-username"
REPO="lambda-valida-pessoa"

# Main branch
gh api repos/$OWNER/$REPO/branches/main/protection -X PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=CI\ Pipeline\ Success \
  --field required_status_checks[contexts][]=Build\ \&\ Unit\ Tests \
  --field required_status_checks[contexts][]=Security\ Scan \
  --field required_status_checks[contexts][]=Terraform\ Validation \
  --field enforce_admins=true \
  --field required_pull_request_reviews[dismiss_stale_reviews]=true \
  --field required_pull_request_reviews[require_code_owner_reviews]=true \
  --field required_pull_request_reviews[required_approving_review_count]=2 \
  --field required_conversation_resolution=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false

echo "✅ Branch protection applied to main"

# Develop branch
gh api repos/$OWNER/$REPO/branches/develop/protection -X PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=Build\ \&\ Unit\ Tests \
  --field required_status_checks[contexts][]=Code\ Quality\ Analysis \
  --field enforce_admins=false \
  --field required_pull_request_reviews[dismiss_stale_reviews]=true \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_conversation_resolution=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false

echo "✅ Branch protection applied to develop"
```

### Uso:
```bash
chmod +x apply-branch-protection.sh
./apply-branch-protection.sh
```

---

## 📊 Verificação

Para verificar se as proteções estão aplicadas:

```bash
# Via GitHub CLI
gh api repos/:owner/:repo/branches/main/protection | jq

# Via browser
# GitHub → Settings → Branches → View rules
```

---

## 🔍 Troubleshooting

### Status checks não aparecem
- Os status checks só aparecem após o primeiro workflow run
- Crie um PR de teste para gerar os checks
- Aguarde o workflow completar
- Os checks aparecerão na lista de seleção

### Não consigo fazer merge
- Verifique se todos os status checks passaram
- Verifique se tem o número mínimo de aprovações
- Verifique se todas as conversões foram resolvidas
- Verifique se a branch está atualizada com a base

### Administradores não conseguem fazer bypass
- Se `include_administrators` está marcado, nem admins podem fazer bypass
- Para emergências, temporariamente desabilite a regra
- Faça o merge necessário
- Reabilite a regra imediatamente

---

**Última atualização:** 2025-12-03

