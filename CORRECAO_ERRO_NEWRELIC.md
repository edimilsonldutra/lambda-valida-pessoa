# ✅ ERRO CORRIGIDO - New Relic Provider

**Data:** 2025-12-03  
**Status:** ✅ RESOLVIDO

---

## 🔴 ERRO ORIGINAL

```
Error: Incorrect attribute value type

  on provider.tf line 31, in provider "newrelic":
  31:   account_id = var.new_relic_account_id

Inappropriate value for attribute "account_id": a number is required.
```

---

## 🔍 CAUSA RAIZ

### Problema 1: Tipo de Variável Incorreto
```terraform
# ❌ ERRADO - vars.tf
variable "new_relic_account_id" {
  type    = string  # ← Provider espera number!
  default = ""
}
```

### Problema 2: Provider Sem Credenciais
Quando New Relic não está configurado, o provider tentava inicializar com valores vazios e causava erro:
```
Error: error initializing newrelic-client-go: 
must use at least one of: ConfigPersonalAPIKey, ConfigAdminAPIKey, ConfigInsightsInsertKey
```

---

## ✅ CORREÇÕES APLICADAS

### Correção 1: Tipo da Variável
**Arquivo:** `infra/terraform/vars.tf`

```terraform
# ✅ CORRETO
variable "new_relic_account_id" {
  description = "New Relic account ID"
  type        = number  # ← Alterado de string para number
  sensitive   = true
  default     = 0       # ← 0 significa desabilitado
}
```

**Mudança:** `type = string` → `type = number`

---

### Correção 2: Provider com Valores Dummy
**Arquivo:** `infra/terraform/provider.tf`

```terraform
# ✅ CORRETO - Provider com fallback para valores dummy
provider "newrelic" {
  account_id = var.new_relic_account_id != 0 ? var.new_relic_account_id : 9999999
  api_key    = var.new_relic_api_key != "" ? var.new_relic_api_key : "dummy-key-not-used"
  region     = var.new_relic_region
}
```

**Explicação:**
- Se `new_relic_account_id` = 0 (default), usa 9999999 como dummy
- Se `new_relic_api_key` = "" (default), usa "dummy-key-not-used"
- Isso permite que o provider seja configurado sem causar erro
- Os recursos New Relic têm `count = 0` quando monitoramento está desabilitado

---

## 📊 RESULTADO

### Antes (Erro):
```bash
$ terraform plan
Error: Incorrect attribute value type
Error: error initializing newrelic-client-go
```

### Depois (Sucesso):
```bash
$ terraform validate
Success! The configuration is valid

$ terraform plan
...plan criado com sucesso...
Saved the plan to: tfplan.binary
```

---

## ⚠️ WARNINGS RESTANTES (Não-Críticos)

Após as correções, apenas warnings informativos permanecem:

### 1. S3 Lifecycle Configuration
```
Warning: Invalid Attribute Combination (cicd-resources.tf)
No attribute specified when one (and only one) of [rule[0].filter,rule[0].prefix] is required
```
**Impacto:** Baixo - Recursos de CI/CD, não afeta deploy principal

### 2. Lambda ignore_changes
```
Warning: Redundant ignore_changes element (lambda.tf)
The attribute last_modified is decided by the provider alone
```
**Impacto:** Nenhum - Apenas informativo

### 3. New Relic Alert Channels
```
Warning: Deprecated Resource (newrelic-alerts.tf)
The newrelic_alert_channel resource is deprecated
```
**Impacto:** Baixo - Funciona normalmente, migração futura recomendada

**Ação:** ✅ Todos esses warnings **NÃO IMPEDEM** o deploy

---

## ✅ STATUS ATUAL

### Configuração Completa:
- ✅ AWS CLI configurado
- ✅ Lambda JAR compilado (19 MB)
- ✅ Secrets gerados (secrets.auto.tfvars)
- ✅ Terraform inicializado
- ✅ Terraform validado
- ✅ **Erro New Relic corrigido**
- ✅ **Terraform plan executado com sucesso**

### Arquivos Modificados:
1. ✅ `infra/terraform/vars.tf` - Tipo da variável corrigido
2. ✅ `infra/terraform/provider.tf` - Provider com valores fallback

---

## 🚀 PRÓXIMO PASSO

O plano foi salvo e está pronto para aplicar:

```bash
cd infra/terraform

# Opção 1: Aplicar o plano salvo
terraform apply "tfplan.binary"

# Opção 2: Aplicar com confirmação interativa
terraform apply

# Opção 3: Aplicar automaticamente (não recomendado para primeira vez)
terraform apply -auto-approve
```

**Tempo estimado:** 15-20 minutos

---

## 📝 O QUE SERÁ CRIADO

Terraform criará aproximadamente **60+ recursos** na AWS:

### Recursos Principais:
- ✅ **VPC e Networking** (VPC, Subnets, NAT Gateway, IGW, Route Tables, Security Groups)
- ✅ **Lambda Function** (Java 21, 512MB, em VPC privada)
- ✅ **RDS PostgreSQL** (db.t4g.micro, 20GB, PostgreSQL 16.3)
- ✅ **API Gateway** (REST API, endpoint /auth, método POST)
- ✅ **Secrets Manager** (credenciais do banco de dados)
- ✅ **CloudWatch** (Log Groups, Alarms, Metrics)
- ✅ **IAM** (Roles, Policies)
- ✅ **S3** (Buckets para CI/CD - opcional)

### Recursos New Relic:
- ⚠️ **Nenhum** - Monitoramento desabilitado (count = 0)

---

## 💰 CUSTOS ESTIMADOS

| Recurso | Custo/Mês |
|---------|-----------|
| Lambda (1M requests) | $0.20 |
| RDS db.t4g.micro | $12.41 |
| NAT Gateway | $32.85 |
| API Gateway (1M req) | $3.50 |
| CloudWatch + Secrets | $0.90 |
| **TOTAL** | **~$50/mês** |

**Otimização DEV:** Desabilite NAT Gateway = ~$17/mês

---

## 🔧 TROUBLESHOOTING

### Se encontrar o erro novamente:

1. **Verificar tipo da variável:**
   ```bash
   grep -A 3 "new_relic_account_id" infra/terraform/vars.tf
   # Deve mostrar: type = number
   ```

2. **Verificar provider:**
   ```bash
   grep -A 3 "provider \"newrelic\"" infra/terraform/provider.tf
   # Deve ter os ternários para valores dummy
   ```

3. **Re-inicializar Terraform:**
   ```bash
   cd infra/terraform
   rm -rf .terraform
   terraform init
   terraform validate
   ```

---

## 📚 DOCUMENTAÇÃO RELACIONADA

- **STATUS_CONFIGURACAO_FINAL.md** - Status completo da configuração
- **ANALISE_CONFIGURACAO_DEPLOY_AWS.md** - Análise detalhada
- **CORRECAO_HELLOWORLD_FUNCTION.md** - Outras correções aplicadas

---

## ✅ CONCLUSÃO

```
╔══════════════════════════════════════════════════════╗
║                                                      ║
║   ✅ ERRO CORRIGIDO COM SUCESSO! ✅                 ║
║                                                      ║
║   Problema: Tipo incorreto em new_relic_account_id  ║
║   Solução: string → number                          ║
║   Bonus: Provider com valores fallback              ║
║                                                      ║
║   🚀 TERRAFORM PLAN EXECUTADO COM SUCESSO!          ║
║                                                      ║
║   Próximo: terraform apply "tfplan.binary"          ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

---

**Última Atualização:** 2025-12-03  
**Problema:** New Relic provider tipo incorreto  
**Status:** ✅ RESOLVIDO  
**Pronto para:** Deploy

