# 🧪 Testes de Monitoramento New Relic

## 📋 Checklist de Validação

Este documento contém testes para validar que o monitoramento New Relic está funcionando corretamente.

---

## ✅ Pré-requisitos

- [ ] Deploy realizado com sucesso
- [ ] NEW_RELIC_LICENSE_KEY configurada
- [ ] Endpoint da API disponível
- [ ] Acesso ao New Relic (https://one.newrelic.com)

---

## 🧪 Testes Funcionais

### Teste 1: Autenticação Bem-Sucedida

**Objetivo:** Validar que métricas de sucesso são coletadas

```bash
# Request
curl -X POST "https://YOUR-API-URL/dev/auth" \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}'

# Resposta esperada: 200 OK com token
```

**Validar no New Relic:**
1. Ir para: APM & Services → ValidaPessoa Lambda
2. Verificar:
   - [ ] Throughput aumentou
   - [ ] Response time registrado
   - [ ] Sem erros
   - [ ] Transaction visível em Transactions

**Validar Métricas Customizadas:**
```nrql
SELECT count(*) FROM Metric 
WHERE metricTimesliceName = 'Custom/Auth/Success' 
SINCE 5 minutes ago
```

**Validar Logs:**
```nrql
SELECT * FROM Log 
WHERE event = 'auth_successful' 
ORDER BY timestamp DESC 
LIMIT 10
```

---

### Teste 2: CPF Inválido

**Objetivo:** Validar que erros de validação são capturados

```bash
curl -X POST "https://YOUR-API-URL/dev/auth" \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678900"}'

# Resposta esperada: 400 Bad Request
```

**Validar no New Relic:**
```nrql
SELECT count(*) FROM Metric 
WHERE metricTimesliceName = 'Custom/CPF/Validation/Failure' 
SINCE 5 minutes ago
```

**Validar Log:**
```nrql
SELECT * FROM Log 
WHERE event = 'cpf_validation_failed' 
ORDER BY timestamp DESC 
LIMIT 1
```

---

### Teste 3: Cliente Não Encontrado

**Objetivo:** Validar métrica de cliente não encontrado

```bash
curl -X POST "https://YOUR-API-URL/dev/auth" \
  -H "Content-Type: application/json" \
  -d '{"cpf":"99999999999"}'

# Resposta esperada: 404 Not Found
```

**Validar:**
```nrql
SELECT count(*) FROM Metric 
WHERE metricTimesliceName = 'Custom/Customer/NotFound' 
SINCE 5 minutes ago
```

---

### Teste 4: Correlation ID

**Objetivo:** Validar rastreamento de requisições

```bash
# Fazer uma requisição
RESPONSE=$(curl -i -X POST "https://YOUR-API-URL/dev/auth" \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}')

# Extrair Correlation ID do header
CORRELATION_ID=$(echo "$RESPONSE" | grep "X-Correlation-ID" | cut -d':' -f2 | tr -d ' \r')

echo "Correlation ID: $CORRELATION_ID"
```

**Validar no New Relic:**
```nrql
SELECT * FROM Log 
WHERE correlationId = 'YOUR-CORRELATION-ID' 
ORDER BY timestamp
```

**Esperado:** Ver todos os logs da requisição:
- auth_request_started
- auth_request_parsed
- customer_found (ou outro evento)
- auth_successful

---

### Teste 5: Distributed Tracing

**Objetivo:** Validar rastreamento distribuído

**Validar no New Relic:**
1. Ir para: APM & Services → ValidaPessoa Lambda → Distributed tracing
2. Selecionar um trace recente
3. Verificar:
   - [ ] Span principal (Lambda handler)
   - [ ] Span de validação CPF
   - [ ] Span de query DynamoDB
   - [ ] Span de geração JWT

---

### Teste 6: Performance Metrics

**Objetivo:** Validar métricas de latência

**Query NRQL:**
```nrql
SELECT 
  average(newrelic.timeslice.value) as 'Avg ms',
  max(newrelic.timeslice.value) as 'Max ms',
  min(newrelic.timeslice.value) as 'Min ms'
FROM Metric 
WHERE metricTimesliceName IN (
  'Custom/CPF/Validation/Duration',
  'Custom/Database/Query/Duration',
  'Custom/JWT/Generation/Duration',
  'Custom/Auth/TotalDuration'
)
FACET metricTimesliceName
SINCE 10 minutes ago
```

**Validar:**
- [ ] Todas as 4 métricas aparecem
- [ ] Valores fazem sentido (milissegundos)

---

### Teste 7: Resource Monitoring

**Objetivo:** Validar monitoramento de recursos

**Query NRQL:**
```nrql
SELECT 
  latest(newrelic.timeslice.value) as 'Current Value'
FROM Metric 
WHERE metricTimesliceName IN (
  'Custom/JVM/Memory/UsagePercent',
  'Custom/JVM/Memory/Used/MB',
  'Custom/JVM/Memory/Free/MB',
  'Custom/JVM/CPU/LoadAverage'
)
FACET metricTimesliceName
```

**Validar:**
- [ ] Memory UsagePercent entre 0-100
- [ ] Memory Used/Free fazem sentido
- [ ] CPU Load registrado

---

### Teste 8: Error Tracking

**Objetivo:** Simular erro e validar captura

```bash
# Simular erro com request mal formado
curl -X POST "https://YOUR-API-URL/dev/auth" \
  -H "Content-Type: application/json" \
  -d '{"invalid":"json"}'

# Resposta esperada: 500 ou 400
```

**Validar:**
```nrql
SELECT count(*) FROM TransactionError 
WHERE appName = 'ValidaPessoa Lambda' 
SINCE 5 minutes ago
```

```nrql
SELECT * FROM Log 
WHERE level = 'ERROR' 
ORDER BY timestamp DESC 
LIMIT 10
```

---

### Teste 9: Alertas

**Objetivo:** Validar que alertas estão configurados

**No New Relic:**
1. Ir para: Alerts & AI → Alert conditions
2. Verificar condições criadas:
   - [ ] High API Latency
   - [ ] Slow Database Queries
   - [ ] High Error Rate
   - [ ] Processing Failures
   - [ ] High Memory Usage
   - [ ] High CPU Load

**Testar alerta (opcional):**
```bash
# Gerar muitos erros rapidamente
for i in {1..20}; do
  curl -X POST "https://YOUR-API-URL/dev/auth" \
    -H "Content-Type: application/json" \
    -d '{"cpf":"00000000000"}' &
done
wait

# Aguardar 5 minutos e verificar se alerta foi disparado
```

---

### Teste 10: Dashboard

**Objetivo:** Validar que dashboard mostra dados

**Passos:**
1. Importar dashboard:
   - New Relic → Dashboards → Import dashboard
   - Upload `newrelic-dashboard.json`
   - Substituir YOUR_ACCOUNT_ID pelo seu account ID

2. Verificar widgets:
   - [ ] Request Rate mostra dados
   - [ ] Average Response Time mostra dados
   - [ ] Error Rate mostra dados
   - [ ] Success vs Failure mostra pizza
   - [ ] Performance metrics aparecem

---

## 🧪 Teste de Carga (Opcional)

**Objetivo:** Validar comportamento sob carga

```bash
# Usar Apache Bench ou similar
ab -n 100 -c 10 -p request.json -T application/json \
  https://YOUR-API-URL/dev/auth

# Arquivo request.json:
# {"cpf":"11144477735"}
```

**Validar no New Relic:**
- [ ] Request Rate spike visível
- [ ] Response Time estável ou aumenta levemente
- [ ] Error Rate permanece baixo
- [ ] Memory Usage registrado
- [ ] Distributed traces aparecem

---

## 🎯 Teste de Alertas

### Teste de Email

1. Ir para: Alerts & AI → Notification channels
2. Verificar canal de email configurado
3. Testar notificação:
   - Gerar erros suficientes para disparar alerta
   - Verificar inbox (incluir spam)

### Teste de Slack (se configurado)

1. Verificar canal Slack configurado
2. Testar notificação
3. Verificar mensagem no canal

---

## 📊 Queries de Validação Completa

### Query 1: Métricas Completas
```nrql
SELECT count(*) 
FROM Metric 
WHERE appName = 'ValidaPessoa Lambda' 
AND metricTimesliceName LIKE 'Custom/%' 
FACET metricTimesliceName 
SINCE 1 hour ago
```

**Esperado:** Ver todas as métricas customizadas listadas

### Query 2: Logs Estruturados
```nrql
SELECT count(*) 
FROM Log 
WHERE service = 'ValidaPessoa' 
FACET event 
SINCE 1 hour ago
```

**Esperado:** Ver diferentes tipos de eventos

### Query 3: Transactions
```nrql
SELECT count(*), 
  average(duration), 
  percentage(count(*), WHERE error IS true) as 'Error %' 
FROM Transaction 
WHERE appName = 'ValidaPessoa Lambda' 
SINCE 1 hour ago
```

### Query 4: Spans
```nrql
SELECT count(*) 
FROM Span 
WHERE appName = 'ValidaPessoa Lambda' 
FACET name 
SINCE 1 hour ago
```

---

## ✅ Checklist Final

Após executar todos os testes, verificar:

### Métricas
- [ ] Custom/Auth/Success registrada
- [ ] Custom/Auth/Failure registrada
- [ ] Custom/CPF/Validation/* registradas
- [ ] Custom/Database/Query/Duration registrada
- [ ] Custom/JWT/Generation/Duration registrada
- [ ] Custom/JVM/Memory/* registradas
- [ ] Custom/JVM/CPU/LoadAverage registrada

### Logs
- [ ] Logs estruturados em JSON
- [ ] Correlation ID presente
- [ ] Request ID presente
- [ ] Eventos corretos (auth_successful, etc)
- [ ] Stack traces em erros

### Tracing
- [ ] Distributed traces aparecem
- [ ] Spans detalhados visíveis
- [ ] Tempo por operação registrado

### Alertas
- [ ] Condições de alerta criadas
- [ ] Canais de notificação configurados
- [ ] Thresholds apropriados

### Dashboard
- [ ] Dashboard importado
- [ ] Widgets mostram dados
- [ ] Gráficos renderizam corretamente

---

## 🐛 Troubleshooting

### Dados não aparecem

**Checklist:**
1. Aguardar 2-3 minutos após requisição
2. Verificar License Key está correta
3. Verificar Lambda Layer anexada
4. Verificar logs do Lambda para erros

**Ver logs:**
```bash
aws logs tail /aws/lambda/valida-pessoa-dev --follow
```

### Métricas faltando

**Validar:**
```bash
# Verificar variáveis de ambiente
aws lambda get-function-configuration \
  --function-name valida-pessoa-dev \
  --query 'Environment.Variables'
```

### Alertas não disparam

**Checklist:**
1. Verificar threshold foi atingido
2. Verificar evaluation period
3. Verificar canal de notificação
4. Testar canal manualmente

---

## 📈 Métricas de Sucesso

A implementação está correta quando:

✅ **100% das requisições** aparecem em Transactions  
✅ **Todas as métricas customizadas** são registradas  
✅ **Logs estruturados** aparecem em JSON  
✅ **Correlation IDs** funcionam  
✅ **Distributed traces** mostram breakdown  
✅ **Alertas** disparam quando apropriado  
✅ **Dashboard** mostra dados em tempo real  

---

## 🎓 Próximos Passos

Após validar tudo:

1. ✅ Ajustar thresholds de alerta baseado em uso real
2. ✅ Criar alertas customizados adicionais
3. ✅ Configurar SLOs (Service Level Objectives)
4. ✅ Implementar Synthetic Monitoring
5. ✅ Integrar com incident management (PagerDuty)

---

**Status:** ✅ Pronto para produção!

