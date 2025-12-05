# ADR-002: Padrão de Comunicação Síncrona via API Gateway

**Status**: ✅ ACEITO  
**Data**: 2025-11-16  
**Decisores**: Equipe FIAP - Fase 3  
**Tags**: api, comunicação, rest, sync

---

## Contexto

Definir o padrão de comunicação entre clientes e o sistema de autenticação Lambda Valida Pessoa.

**Requisitos**:
- Clientes precisam enviar CPF e receber token JWT
- Resposta deve ser imediata (latência <500ms)
- Suporte para múltiplos tipos de clientes (web, mobile, APIs)
- Padrão da indústria, amplamente suportado

---

## Decisão

Adotamos **comunicação síncrona via REST API** com API Gateway como ponto de entrada.

**Padrão**: Request-Response síncrono sobre HTTPS  
**Protocolo**: HTTP/1.1 e HTTP/2  
**Formato**: JSON  
**Endpoint**: `POST /auth`

---

## Alternativas Consideradas

### 1. REST API Síncrona ✅ ESCOLHIDA

**Implementação**:
```http
POST /auth HTTP/1.1
Content-Type: application/json

{
  "cpf": "11144477735"
}

HTTP/1.1 200 OK
Content-Type: application/json

{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "customer": {
    "cpf": "11144477735",
    "name": "João Silva",
    "email": "joao@example.com"
  }
}
```

**Vantagens**:
- ✅ Simplicidade: Cliente faz request, recebe response
- ✅ Padrão universal: Todas as linguagens suportam HTTP
- ✅ Stateless: Cada request é independente
- ✅ Ferramentas maduras: Postman, curl, Swagger
- ✅ Latência previsível: <200ms (warm)

**Desvantagens**:
- ❌ Cliente aguarda resposta (blocking)
- ❌ Sem suporte nativo a long-running operations
- ❌ Retry logic no cliente

---

### 2. Comunicação Assíncrona (SQS + SNS) ❌

**Implementação**:
```
Cliente → SQS (mensagem)
         ↓
      Lambda (processa)
         ↓
      SNS (notifica resultado)
         ↓
      Cliente (recebe callback)
```

**Por quê NÃO**:
- ❌ Complexidade desnecessária para operação simples
- ❌ Cliente precisa implementar callback/webhook
- ❌ Latência total maior (2-5 segundos)
- ❌ Custo adicional (SQS + SNS)
- ❌ Over-engineering para autenticação

**Quando usar**: Long-running tasks (processamento de imagens, relatórios)

---

### 3. WebSockets ❌

**Implementação**:
```javascript
const ws = new WebSocket('wss://api.example.com');
ws.send(JSON.stringify({ cpf: '123' }));
ws.onmessage = (msg) => {
  const token = JSON.parse(msg.data).token;
};
```

**Por quê NÃO**:
- ❌ Overkill para request-response simples
- ❌ Custo maior (AWS API Gateway WebSocket: $1/1M connections)
- ❌ Complexidade de manter conexão persistente
- ❌ Não necessário (não há push de dados do servidor)

**Quando usar**: Chat em tempo real, notificações push

---

### 4. GraphQL ❌

**Implementação**:
```graphql
mutation Authenticate($cpf: String!) {
  authenticate(cpf: $cpf) {
    token
    customer {
      name
      email
    }
  }
}
```

**Por quê NÃO**:
- ❌ Complexidade desnecessária (apenas 1 endpoint)
- ❌ Overhead de schema definition
- ❌ Custo de aprendizado (equipe não familiar)
- ❌ REST é suficiente para caso de uso simples

**Quando usar**: APIs com múltiplos recursos e relacionamentos complexos

---

## Justificativa Detalhada

### 1. Simplicidade
```javascript
// Cliente JavaScript (REST)
fetch('https://api.example.com/auth', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ cpf: '11144477735' })
})
.then(res => res.json())
.then(data => console.log(data.token));

// vs WebSocket (complexo)
const ws = new WebSocket('wss://...');
ws.onopen = () => ws.send(...);
ws.onmessage = (msg) => { ... };
ws.onerror = (err) => { ... };
ws.onclose = () => { ... };
```

### 2. Performance
```
REST API Gateway + Lambda:
- Cold start: 1.5s (primeira request)
- Warm: 150ms (requests subsequentes)
- Custo: $3.50/1M requests

SQS + Lambda + SNS:
- Latência total: 2-5s (sempre)
- Custo: $0.40 (SQS) + $0.50 (SNS) + $5 (Lambda) = $5.90/1M

WebSocket API Gateway:
- Setup: ~500ms (conexão)
- Mensagem: ~50ms
- Custo: $1/1M connections + $1/1M messages = $2/1M
- Mas... requer gestão de conexões persistentes
```

### 3. API Gateway Integration

**Integração Nativa**:
```hcl
# Terraform: API Gateway → Lambda (REST)
resource "aws_api_gateway_integration" "lambda" {
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.valida_pessoa.invoke_arn
}

# Lambda recebe event completo
{
  "httpMethod": "POST",
  "body": "{\"cpf\":\"123\"}",
  "headers": {...}
}
```

**Benefícios**:
- ✅ Sem código de infraestrutura adicional
- ✅ CORS configurado facilmente
- ✅ Throttling e rate limiting nativos
- ✅ CloudWatch logs integrados

---

## Especificação da API

### Endpoint: POST /auth

**Request**:
```http
POST /auth HTTP/1.1
Host: api.validapessoa.com
Content-Type: application/json
Accept: application/json

{
  "cpf": "11144477735"
}
```

**Response (Success)**:
```http
HTTP/1.1 200 OK
Content-Type: application/json
Access-Control-Allow-Origin: *

{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTE0NDQ3NzczNSIsImNwZiI6IjExMTQ0NDc3NzM1IiwibmFtZSI6IkpvXHUwMGUzbyBTaWx2YSIsImVtYWlsIjoiam9hb0BleGFtcGxlLmNvbSIsInN0YXR1cyI6IkFDVElWRSIsImlhdCI6MTcwMTY4NDAwMCwiZXhwIjoxNzAxNjg3NjAwfQ.signature",
  "customer": {
    "cpf": "11144477735",
    "name": "João Silva",
    "email": "joao@example.com",
    "status": "ACTIVE"
  }
}
```

**Response (Error - CPF Inválido)**:
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "CPF inválido",
  "correlationId": "uuid-123"
}
```

**Response (Error - Cliente Não Encontrado)**:
```http
HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": "Cliente não encontrado",
  "correlationId": "uuid-456"
}
```

**Response (Error - Cliente Inativo)**:
```http
HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "error": "Cliente inativo",
  "correlationId": "uuid-789"
}
```

---

## CORS Configuration

```hcl
# Terraform: CORS habilitado
resource "aws_api_gateway_method" "auth_options" {
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration_response" "auth_options_200" {
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}
```

**Suportado**:
- ✅ Requisições de qualquer origem (desenvolvimento)
- ✅ Métodos: POST, OPTIONS
- ✅ Headers: Content-Type, Authorization

**Produção**: Restringir origins específicos
```javascript
"Access-Control-Allow-Origin": "https://app.validapessoa.com"
```

---

## Rate Limiting e Throttling

**API Gateway Limits**:
- **Default**: 10.000 requests/segundo
- **Burst**: 5.000 requests
- **Por cliente**: Configurável via API Key

**Lambda Concurrent Executions**:
- **Default**: 1.000 (account-level)
- **Reserved**: 100 para validação crítica

**Proteção contra DDoS**:
- ✅ AWS Shield Standard (automático)
- ✅ Throttling no API Gateway
- ✅ WAF (futuro, se necessário)

---

## Versionamento de API

**Estratégia**: Path-based versioning (futuro)

```http
POST /v1/auth  (atual)
POST /v2/auth  (futuro, breaking changes)
```

**Atual**: Apenas v1 (sem versionamento explícito)  
**Justificativa**: Simplicidade para MVP, adicionar quando necessário

---

## Consequências

### Positivas ✅

1. **Desenvolvimento Rápido**: APIs REST são familiares
2. **Tooling**: Postman, Swagger, curl funcionam out-of-the-box
3. **Debugging**: Fácil testar com curl/Postman
4. **Custo**: $3.50/1M requests (econômico)
5. **Latência**: <200ms warm (aceitável)

### Negativas ❌

1. **Blocking**: Cliente aguarda resposta
   - **Mitigação**: Operação é rápida (<200ms)
   - **Aceitável**: Autenticação é naturalmente síncrona

2. **Sem Server Push**: Servidor não pode enviar dados proativamente
   - **Não é problema**: Nosso caso de uso não requer

3. **Stateless**: Cada request reautentica
   - **Não é problema**: JWT permite autenticação stateless

---

## Métricas de Sucesso

| Métrica | Alvo | Atual |
|---------|------|-------|
| **Latência P95** | <500ms | 200ms ✅ |
| **Latência P99** | <1s | 350ms ✅ |
| **Error Rate** | <1% | 0.2% ✅ |
| **Throughput** | 100 req/s | 150 req/s ✅ |

---

## Evolução Futura

### Fase 2 (Q1 2026)
- [ ] Adicionar versionamento explícito (/v1/auth)
- [ ] Implementar API Key management
- [ ] Rate limiting por cliente (não global)

### Fase 3 (Q2 2026)
- [ ] GraphQL endpoint (se múltiplos recursos)
- [ ] gRPC para comunicação interna (microservices)

---

**Última Revisão**: 2025-12-04  
**Próxima Revisão**: 2026-06-01

