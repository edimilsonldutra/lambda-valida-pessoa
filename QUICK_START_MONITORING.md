# 🎯 Quick Start - New Relic Monitoring

## 📋 Pré-requisitos

- Conta New Relic (gratuita): https://newrelic.com/signup
- AWS Account configurada
- Java 21, Maven, Terraform instalados

---

## 🚀 Setup Rápido (5 minutos)

### 1️⃣ Obter License Key do New Relic

```bash
# 1. Acesse https://one.newrelic.com
# 2. Vá para: Account settings → API keys
# 3. Copie sua License Key
```

### 2️⃣ Configurar Variável de Ambiente

**Linux/Mac:**
```bash
export NEW_RELIC_LICENSE_KEY="your-license-key-here"
```

**Windows (PowerShell):**
```powershell
$env:NEW_RELIC_LICENSE_KEY="your-license-key-here"
```

**Windows (CMD):**
```cmd
set NEW_RELIC_LICENSE_KEY=your-license-key-here
```

### 3️⃣ Configurar Terraform

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` e adicione:

```hcl
new_relic_license_key = "your-license-key-here"
enable_new_relic_monitoring = true

# Notificações (opcional)
alert_email_recipients = "seu-email@empresa.com"
```

### 4️⃣ Deploy

**Linux/Mac:**
```bash
chmod +x deploy-with-monitoring.sh
./deploy-with-monitoring.sh
```

**Windows:**
```cmd
deploy-with-monitoring.bat
```

### 5️⃣ Verificar no New Relic

Acesse: https://one.newrelic.com

Você verá:
- **APM & Services** → ValidaPessoa Lambda
- Métricas em tempo real
- Distributed tracing
- Logs estruturados

---

## 📊 O Que É Monitorado

### ✅ Performance
- ⏱️ Latência de API (alerta se > 3s)
- 🔍 Tempo de validação de CPF
- 💾 Latência de queries no DynamoDB
- 🔐 Tempo de geração JWT

### ✅ Recursos
- 💻 Uso de memória JVM (alerta se > 90%)
- ⚡ CPU load average
- 📈 Throughput (requisições/minuto)

### ✅ Erros
- ❌ Taxa de erro (alerta se > 5%)
- 🔴 Falhas de processamento
- ⏰ Timeouts da Lambda

### ✅ Logs Estruturados (JSON)
```json
{
  "timestamp": "2025-12-02T10:30:45.123Z",
  "level": "INFO",
  "event": "auth_successful",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000",
  "cpf": "111.***.*-35",
  "total_duration_ms": 245
}
```

---

## 🔍 Queries NRQL Úteis

### Ver Latência Média
```nrql
SELECT average(duration) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
TIMESERIES
```

### Rastrear Requisição por Correlation ID
```nrql
SELECT * 
FROM Log 
WHERE correlationId = 'YOUR-CORRELATION-ID' 
ORDER BY timestamp
```

### Taxa de Erro
```nrql
SELECT percentage(count(*), WHERE error IS true) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda'
```

### Top Erros
```nrql
SELECT count(*) 
FROM TransactionError 
FACET error.class, error.message 
SINCE 1 day ago
```

---

## 🚨 Alertas Configurados

| Alerta | Threshold | Ação |
|--------|-----------|------|
| Alta Latência | > 3 segundos | Email |
| Taxa de Erro | > 5% | Email + Slack |
| Memória Alta | > 90% | Email |
| Query Lenta | > 1 segundo | Email |
| Falhas | > 10 em 5min | Email + PagerDuty (prod) |

---

## 📱 Integração com Slack (Opcional)

1. Crie um Webhook no Slack:
   - https://api.slack.com/messaging/webhooks

2. Configure no `terraform.tfvars`:
```hcl
enable_slack_notifications = true
slack_webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
slack_channel = "#alerts"
```

3. Redeploy:
```bash
terraform apply
```

---

## 📞 Integração com PagerDuty (Produção)

1. Obtenha Integration Key do PagerDuty

2. Configure no `terraform.tfvars`:
```hcl
enable_pagerduty = true
pagerduty_service_key = "your-integration-key"
```

---

## 🎨 Dashboard Recomendado

Crie um dashboard no New Relic com:

### Widget 1: Request Rate
```nrql
SELECT rate(count(*), 1 minute) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
TIMESERIES
```

### Widget 2: Response Time
```nrql
SELECT average(duration), percentile(duration, 95, 99) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
TIMESERIES
```

### Widget 3: Error Rate
```nrql
SELECT percentage(count(*), WHERE error IS true) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
TIMESERIES
```

### Widget 4: Memory Usage
```nrql
SELECT average(newrelic.timeslice.value) 
FROM Metric 
WHERE metricTimesliceName = 'Custom/JVM/Memory/UsagePercent' 
TIMESERIES
```

---

## 🔧 Troubleshooting

### Problema: Dados não aparecem no New Relic

**Checklist:**
- [ ] NEW_RELIC_LICENSE_KEY está configurada?
- [ ] Lambda Layer está anexada?
- [ ] Aguardou 2-3 minutos após deploy?
- [ ] Fez pelo menos 1 request no endpoint?

**Verificar logs:**
```bash
aws logs tail /aws/lambda/valida-pessoa-dev --follow
```

### Problema: Alertas não estão disparando

**Checklist:**
- [ ] Email configurado em `alert_email_recipients`?
- [ ] Condições de alerta foram atingidas?
- [ ] Verificar spam/lixo eletrônico
- [ ] Confirmar no New Relic: Alerts & AI → Alert Conditions

---

## 📚 Documentação Adicional

- [📖 NEW_RELIC_MONITORING.md](NEW_RELIC_MONITORING.md) - Guia completo
- [🔗 New Relic Docs](https://docs.newrelic.com/docs/serverless-function-monitoring/aws-lambda-monitoring/)
- [🔗 NRQL Reference](https://docs.newrelic.com/docs/nrql/nrql-syntax-clauses-functions/)

---

## 💡 Dicas

1. **Use Correlation IDs**: Sempre rastreie requisições com correlation ID
2. **Configure SLOs**: Defina Service Level Objectives baseados em métricas reais
3. **Revise Dashboards**: Analise semanalmente para identificar tendências
4. **Customize Alertas**: Ajuste thresholds baseado no seu tráfego
5. **Log Estruturado**: Sempre use JSON para facilitar queries

---

## 🎓 Próximos Passos

1. ✅ Configure alertas personalizados
2. ✅ Crie dashboards customizados
3. ✅ Configure integração com Slack
4. ✅ Defina SLOs (Service Level Objectives)
5. ✅ Configure Synthetic Monitoring para health checks

---

## 💰 Custos

**New Relic:**
- Free tier: 100 GB/mês de dados
- Suficiente para ~1M requests/mês

**AWS Lambda + Layer:**
- New Relic Layer: Gratuita
- Mínimo overhead (~10ms por request)

---

## 🆘 Suporte

**Problemas com New Relic:**
- https://discuss.newrelic.com/
- support@newrelic.com

**Problemas com o Projeto:**
- Abra uma issue no repositório
- Contate o time FIAP

---

## ✅ Checklist de Deploy

- [ ] New Relic account criada
- [ ] License key obtida
- [ ] Variável de ambiente configurada
- [ ] terraform.tfvars atualizado
- [ ] Build executado com sucesso
- [ ] Deploy realizado
- [ ] Endpoint testado
- [ ] Dashboard no New Relic verificado
- [ ] Alertas configurados
- [ ] Email de notificação testado
- [ ] Documentação revisada

---

**🎉 Pronto! Seu Lambda está completamente monitorado!**

Acesse: https://one.newrelic.com

