# 🔍 Monitoramento New Relic - Guia Completo

## 📊 Visão Geral

Este projeto está completamente integrado com New Relic para monitoramento abrangente de:
- ✅ Latência das APIs
- ✅ Consumo de recursos (CPU, memória)
- ✅ Health checks e uptime
- ✅ Alertas para falhas
- ✅ Logs estruturados em JSON com correlação de requisições

---

## 🚀 Configuração Inicial

### 1. Obter License Key do New Relic

1. Acesse https://one.newrelic.com
2. Vá para: **Account settings** → **API keys**
3. Copie sua **License Key** (ou crie uma nova)

### 2. Configurar Variáveis de Ambiente

```bash
# Adicionar ao AWS Lambda
NEW_RELIC_LICENSE_KEY=your-license-key-here
NEW_RELIC_APP_NAME=ValidaPessoa Lambda
NEW_RELIC_LOG_LEVEL=info
NEW_RELIC_DISTRIBUTED_TRACING_ENABLED=true
ENVIRONMENT=production
```

### 3. Deploy com New Relic Layer

O New Relic fornece uma Lambda Layer oficial para Java:

```bash
# ARN da Layer (us-east-1)
arn:aws:lambda:us-east-1:451483290750:layer:NewRelicJava21:1

# Adicionar ao template.yaml ou Terraform
```

---

## 📡 Métricas Coletadas

### 📈 Métricas de Performance

| Métrica | Descrição | Threshold de Alerta |
|---------|-----------|---------------------|
| `Custom/Auth/TotalDuration` | Tempo total de processamento | > 3000ms |
| `Custom/CPF/Validation/Duration` | Tempo de validação de CPF | > 500ms |
| `Custom/Database/Query/Duration` | Latência de query no DynamoDB | > 1000ms |
| `Custom/JWT/Generation/Duration` | Tempo de geração de token JWT | > 200ms |

### 📊 Métricas de Negócio

| Métrica | Descrição |
|---------|-----------|
| `Custom/Auth/Success` | Total de autenticações bem-sucedidas |
| `Custom/Auth/Failure` | Total de autenticações falhadas |
| `Custom/CPF/Validation/Success` | CPFs válidos processados |
| `Custom/CPF/Validation/Failure` | CPFs inválidos detectados |
| `Custom/Customer/NotFound` | Clientes não encontrados |
| `Custom/Customer/Inactive` | Tentativas de clientes inativos |
| `Custom/Errors/Total` | Total de erros |

### 💻 Métricas de Recursos

| Métrica | Descrição | Threshold de Alerta |
|---------|-----------|---------------------|
| `Custom/JVM/Memory/UsagePercent` | Uso de memória JVM | > 90% |
| `Custom/JVM/Memory/Used/MB` | Memória utilizada em MB | - |
| `Custom/JVM/Memory/Free/MB` | Memória livre em MB | < 50MB |
| `Custom/JVM/CPU/LoadAverage` | Carga média de CPU | > 0.8 |

---

## 🔍 Distributed Tracing

Cada requisição é rastreada de ponta a ponta:

```
┌──────────────────────────────────────────────────────────┐
│ API Gateway Request                                       │
│ ↓                                                         │
│ Lambda Handler (ValidaPessoaFunction)                    │
│   ├─ CPF Validation (DocumentoValidator)                │
│   ├─ Database Query (CustomerService → DynamoDB)        │
│   └─ JWT Generation (JWTService)                        │
└──────────────────────────────────────────────────────────┘
```

**Correlation ID**: Todas as requisições incluem um `correlationId` único que permite rastrear logs e traces relacionados.

---

## 📝 Logs Estruturados (JSON)

### Formato de Log

```json
{
  "timestamp": "2025-12-02T10:30:45.123Z",
  "level": "INFO",
  "event": "auth_successful",
  "service": "ValidaPessoa",
  "version": "1.0",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000",
  "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef",
  "awsRequestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef",
  "cpf": "111.***.*-35",
  "customer_name": "João Silva",
  "total_duration_ms": 245,
  "validation_duration_ms": 12,
  "db_duration_ms": 187,
  "jwt_duration_ms": 46
}
```

### Eventos de Log

| Evento | Nível | Descrição |
|--------|-------|-----------|
| `auth_request_started` | INFO | Requisição de autenticação iniciada |
| `auth_request_parsed` | INFO | Request body parseado com sucesso |
| `cpf_validation_failed` | WARN | CPF inválido detectado |
| `customer_not_found` | WARN | Cliente não encontrado no banco |
| `customer_inactive` | WARN | Cliente com status inativo |
| `auth_successful` | INFO | Autenticação bem-sucedida |
| `auth_request_failed` | ERROR | Erro no processamento |

---

## 🚨 Alertas Configurados

### 1. Alta Latência de API

```nrql
SELECT average(duration) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
FACET name
```

**Threshold**: > 3 segundos  
**Ação**: Notificação via email/Slack

### 2. Taxa de Erro Elevada

```nrql
SELECT percentage(count(*), WHERE error IS true) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda'
```

**Threshold**: > 5%  
**Ação**: PagerDuty alert

### 3. Alto Uso de Memória

```nrql
SELECT max(newrelic.timeslice.value) 
FROM Metric 
WHERE metricTimesliceName = 'Custom/JVM/Memory/UsagePercent' 
AND appName = 'ValidaPessoa Lambda'
```

**Threshold**: > 90%  
**Ação**: Auto-scaling trigger

### 4. Falhas no Processamento

```nrql
SELECT count(*) 
FROM Log 
WHERE event = 'auth_request_failed' 
AND service = 'ValidaPessoa'
```

**Threshold**: > 10 em 5 minutos  
**Ação**: Incident creation

### 5. Database Slow Queries

```nrql
SELECT average(newrelic.timeslice.value) 
FROM Metric 
WHERE metricTimesliceName = 'Custom/Database/Query/Duration' 
AND appName = 'ValidaPessoa Lambda'
```

**Threshold**: > 1 segundo  
**Ação**: Performance investigation

---

## 🔧 Queries NRQL Úteis

### Ver Todas as Requisições com Latência

```nrql
SELECT timestamp, duration, error, correlationId, cpf 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
ORDER BY duration DESC 
LIMIT 100
```

### Acompanhar Correlação de Requisição

```nrql
SELECT * 
FROM Log 
WHERE correlationId = 'YOUR-CORRELATION-ID' 
ORDER BY timestamp
```

### Análise de Erros

```nrql
SELECT count(*) 
FROM TransactionError 
WHERE appName = 'ValidaPessoa Lambda' 
FACET error.class, error.message 
SINCE 1 day ago
```

### Performance por Operação

```nrql
SELECT average(duration), percentile(duration, 95, 99) 
FROM Span 
WHERE appName = 'ValidaPessoa Lambda' 
FACET name 
SINCE 1 hour ago
```

### Taxa de Sucesso vs Falha

```nrql
SELECT count(*) 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
FACET CASES(
  WHERE error IS false AS 'Success',
  WHERE error IS true AS 'Failure'
) 
TIMESERIES AUTO
```

---

## 📊 Dashboards Recomendados

### Dashboard: Authentication Overview

```json
{
  "name": "ValidaPessoa - Authentication Overview",
  "widgets": [
    {
      "title": "Request Rate",
      "query": "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = 'ValidaPessoa Lambda' TIMESERIES"
    },
    {
      "title": "Average Response Time",
      "query": "SELECT average(duration) FROM Transaction WHERE appName = 'ValidaPessoa Lambda' TIMESERIES"
    },
    {
      "title": "Error Rate",
      "query": "SELECT percentage(count(*), WHERE error IS true) FROM Transaction WHERE appName = 'ValidaPessoa Lambda' TIMESERIES"
    },
    {
      "title": "Success vs Failure",
      "query": "SELECT count(*) FROM Transaction WHERE appName = 'ValidaPessoa Lambda' FACET CASES(WHERE error IS false AS 'Success', WHERE error IS true AS 'Failure')"
    }
  ]
}
```

### Dashboard: Performance Metrics

```json
{
  "name": "ValidaPessoa - Performance Metrics",
  "widgets": [
    {
      "title": "CPF Validation Time",
      "query": "SELECT average(newrelic.timeslice.value) FROM Metric WHERE metricTimesliceName = 'Custom/CPF/Validation/Duration' TIMESERIES"
    },
    {
      "title": "Database Query Time",
      "query": "SELECT average(newrelic.timeslice.value) FROM Metric WHERE metricTimesliceName = 'Custom/Database/Query/Duration' TIMESERIES"
    },
    {
      "title": "JWT Generation Time",
      "query": "SELECT average(newrelic.timeslice.value) FROM Metric WHERE metricTimesliceName = 'Custom/JWT/Generation/Duration' TIMESERIES"
    },
    {
      "title": "Memory Usage",
      "query": "SELECT average(newrelic.timeslice.value) FROM Metric WHERE metricTimesliceName = 'Custom/JVM/Memory/UsagePercent' TIMESERIES"
    }
  ]
}
```

---

## 🎯 Health Check Endpoint

Adicione um endpoint `/health` para monitoring:

```bash
GET /health

Response:
{
  "status": "healthy",
  "timestamp": 1701518400000,
  "memory": {
    "used_mb": 128,
    "max_mb": 512,
    "free_mb": 384,
    "usage_percent": 25.0
  },
  "dependencies": {
    "dynamodb": "healthy"
  }
}
```

---

## 🔄 Integração com Kubernetes

Para ambiente Kubernetes (futuro), configure:

```yaml
# New Relic Infrastructure Agent
apiVersion: v1
kind: ConfigMap
metadata:
  name: newrelic-infrastructure-config
data:
  newrelic-infra.yml: |
    license_key: YOUR_LICENSE_KEY
    custom_attributes:
      environment: production
      service: valida-pessoa
```

**Métricas Kubernetes Monitoradas**:
- CPU usage per pod
- Memory usage per pod
- Pod restart count
- Network I/O
- Disk I/O

---

## 📚 Recursos Adicionais

- [New Relic AWS Lambda Monitoring](https://docs.newrelic.com/docs/serverless-function-monitoring/aws-lambda-monitoring/)
- [Java Agent Configuration](https://docs.newrelic.com/docs/apm/agents/java-agent/configuration/)
- [NRQL Reference](https://docs.newrelic.com/docs/nrql/nrql-syntax-clauses-functions/)
- [Alert Conditions](https://docs.newrelic.com/docs/alerts-applied-intelligence/new-relic-alerts/alert-conditions/)

---

## 🎓 Boas Práticas

1. **Sempre use correlation IDs** para rastreamento de requisições
2. **Configure alertas progressivos** (warn, critical)
3. **Revise dashboards semanalmente** para identificar tendências
4. **Mantenha logs estruturados** para facilitar análise
5. **Configure SLOs** (Service Level Objectives) baseados em métricas reais
6. **Use distributed tracing** para debug de problemas de performance
7. **Monitore custos da AWS** junto com performance

---

## 🛠️ Troubleshooting

### Problema: New Relic não está coletando dados

**Solução**:
1. Verificar se `NEW_RELIC_LICENSE_KEY` está configurada
2. Checar logs do Lambda para erros do agente New Relic
3. Confirmar que a Layer está anexada à função

### Problema: Logs não aparecem no New Relic

**Solução**:
1. Verificar configuração do `logback.xml`
2. Confirmar que `application_logging.forwarding.enabled = true` no `newrelic.yml`
3. Checar permissões do CloudWatch Logs

### Problema: Métricas customizadas não aparecem

**Solução**:
1. Aguardar até 5 minutos para propagação
2. Verificar sintaxe do `NewRelic.recordMetric()`
3. Confirmar que o nome da métrica não ultrapassa 255 caracteres

