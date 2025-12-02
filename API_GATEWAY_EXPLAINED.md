# 🚀 API Gateway - Explicação Completa

## 📋 Visão Geral

O API Gateway do projeto é um **REST API Regional** que atua como porta de entrada para a função Lambda de validação de pessoas. Ele gerencia autenticação, throttling, logs e CORS.

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ HTTPS Request
                           │ POST /auth
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    API GATEWAY (REST API)                       │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  Endpoint: https://{api-id}.execute-api.{region}.     │    │
│  │            amazonaws.com/{stage}/auth                   │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  RESOURCE: /auth                                         │  │
│  │                                                          │  │
│  │  ┌─────────────────┐        ┌──────────────────┐       │  │
│  │  │  POST /auth     │        │  OPTIONS /auth   │       │  │
│  │  │  (Principal)    │        │  (CORS Preflight)│       │  │
│  │  └────────┬────────┘        └────────┬─────────┘       │  │
│  │           │                           │                 │  │
│  │           │ AWS_PROXY                 │ MOCK            │  │
│  │           │                           │                 │  │
│  └───────────┼───────────────────────────┼─────────────────┘  │
│              │                           │                     │
│  ┌───────────▼───────────────────────────▼─────────────────┐  │
│  │  FEATURES:                                              │  │
│  │  • Throttling (5000 burst, 10000 req/s)               │  │
│  │  • CloudWatch Logs                                      │  │
│  │  • X-Ray Tracing (prod)                                │  │
│  │  • Usage Plan                                           │  │
│  │  • CORS Enabled                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ Lambda Invoke
                           │ (via IAM Permission)
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    LAMBDA FUNCTION                              │
│              ValidaPessoaFunction::handleRequest                │
│                                                                  │
│  1. Valida CPF/CNPJ                                             │
│  2. Busca pessoa no RDS PostgreSQL                              │
│  3. Verifica status ACTIVE                                      │
│  4. Gera JWT Token                                              │
│  5. Retorna AuthResponse com token                              │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Componentes Principais

### 1. **REST API**
```hcl
resource "aws_api_gateway_rest_api" "api"
```
- **Nome**: `valida-pessoa-api-{environment}`
- **Tipo**: REGIONAL (não usa CloudFront)
- **Endpoint**: `https://{api-id}.execute-api.us-east-1.amazonaws.com`

### 2. **Resource: /auth**
```hcl
resource "aws_api_gateway_resource" "auth"
```
- **Path**: `/auth`
- **Função**: Endpoint único para validação de documentos

### 3. **Method: POST /auth**
```hcl
resource "aws_api_gateway_method" "auth_post"
```
- **HTTP Method**: POST
- **Authorization**: NONE (sem autenticação, pois este endpoint GERA o token)
- **Request**: Requer header `Content-Type`
- **Body Esperado**:
```json
{
  "cpf": "12345678901"  // CPF ou CNPJ (só números)
}
```

### 4. **Integration: AWS_PROXY**
```hcl
resource "aws_api_gateway_integration" "lambda_integration"
```
- **Tipo**: AWS_PROXY (repassa request completo para Lambda)
- **Target**: Lambda `valida_pessoa`
- **Vantagens do PROXY**:
  - Lambda recebe headers, body, queryParams, etc.
  - Lambda controla o response (status, headers, body)
  - Não precisa mapear request/response no API Gateway

### 5. **Method: OPTIONS /auth (CORS)**
```hcl
resource "aws_api_gateway_method" "auth_options"
```
- **Finalidade**: Preflight request para CORS
- **Tipo**: MOCK (resposta automática sem invocar Lambda)
- **Headers retornados**:
  - `Access-Control-Allow-Origin: *`
  - `Access-Control-Allow-Methods: POST,OPTIONS`
  - `Access-Control-Allow-Headers: Content-Type,X-Amz-Date,Authorization...`

### 6. **Lambda Permission**
```hcl
resource "aws_lambda_permission" "api_gateway"
```
- **Permite**: API Gateway invocar a Lambda
- **Principal**: `apigateway.amazonaws.com`
- **Source ARN**: Qualquer método/path da API (`/*/*`)

### 7. **Deployment & Stage**
```hcl
resource "aws_api_gateway_deployment" "deployment"
resource "aws_api_gateway_stage" "stage"
```
- **Stage Name**: `dev`, `staging` ou `prod` (conforme variável)
- **URL Final**: `https://{api-id}.execute-api.us-east-1.amazonaws.com/{stage}/auth`
- **Redeploy Automático**: Quando recursos/métodos/integrações mudam

### 8. **CloudWatch Logs**
```hcl
resource "aws_cloudwatch_log_group" "api_gateway_logs"
```
- **Logs Capturados**:
  - Request ID
  - IP do cliente
  - Método HTTP
  - Path
  - Status code
  - Response length
  - Tempo de request
- **Retenção**: 14 dias (configurável)

### 9. **Usage Plan**
```hcl
resource "aws_api_gateway_usage_plan" "usage_plan"
```
- **Throttling**:
  - **Burst Limit**: 5000 requisições simultâneas
  - **Rate Limit**: 10000 requisições/segundo
- **Proteção**: Contra DDoS e uso abusivo

## 📡 Fluxo de Requisição Completo

### 1️⃣ Cliente envia POST
```bash
curl -X POST https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/auth \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678901"}'
```

### 2️⃣ API Gateway processa
1. ✅ Valida método permitido (POST)
2. ✅ Verifica throttling (dentro do limite?)
3. ✅ Aplica CORS headers (se necessário)
4. ✅ Registra no CloudWatch Logs
5. ✅ Invoca Lambda via AWS_PROXY

### 3️⃣ Lambda executa
```java
ValidaPessoaFunction.handleRequest(APIGatewayProxyRequestEvent, Context)
```
1. Parse do body JSON
2. Valida CPF/CNPJ usando `DocumentoValidator`
3. Busca pessoa no RDS PostgreSQL
4. Verifica se status é ACTIVE
5. Gera JWT token
6. Retorna `APIGatewayProxyResponseEvent`:
```json
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"token\":\"eyJ...\", \"customer\":{...}}"
}
```

### 4️⃣ API Gateway retorna
- Status: 200 OK (ou erro)
- Headers: CORS + Content-Type
- Body: JSON com token e dados do customer

### 5️⃣ CloudWatch registra
```json
{
  "requestId": "abc-123",
  "ip": "203.0.113.42",
  "requestTime": "01/Dec/2025:18:30:00 +0000",
  "httpMethod": "POST",
  "resourcePath": "/auth",
  "status": 200,
  "responseLength": 523
}
```

## 🔒 CORS (Cross-Origin Resource Sharing)

### Por que CORS?
Permite que aplicações web (frontend) em outros domínios chamem a API.

### Como funciona?

**Preflight Request (Browser automático)**:
```http
OPTIONS /auth HTTP/1.1
Origin: https://example.com
```

**Response (MOCK integration)**:
```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST,OPTIONS
Access-Control-Allow-Headers: Content-Type,...
```

**Request Real**:
```http
POST /auth HTTP/1.1
Content-Type: application/json
Origin: https://example.com

{"cpf":"12345678901"}
```

**Response com CORS**:
```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Content-Type: application/json

{"token":"eyJ...","customer":{...}}
```

## ⚙️ Configurações Importantes

### Throttling (Proteção contra abuso)
```hcl
throttle_settings {
  burst_limit = 5000   # Máximo de requisições simultâneas
  rate_limit  = 10000  # Máximo de req/segundo
}
```

**Comportamento**:
- Se exceder: retorna `429 Too Many Requests`
- Ideal para produção: ajustar conforme capacidade do RDS

### Logs Structure
```json
{
  "requestId": "UUID único da requisição",
  "ip": "IP do cliente",
  "caller": "Identity do caller (se autenticado)",
  "user": "User (se autenticado)",
  "requestTime": "Timestamp ISO",
  "httpMethod": "POST",
  "resourcePath": "/auth",
  "status": 200,
  "protocol": "HTTP/1.1",
  "responseLength": 523
}
```

### X-Ray Tracing (Produção)
```hcl
xray_tracing_enabled = var.enable_xray_tracing
```
- **Dev**: Desabilitado (custo)
- **Prod**: Habilitado (observabilidade)
- **Rastreia**: API Gateway → Lambda → RDS

## 🎯 Endpoints Disponíveis

| Método | Path | Função | Autenticação |
|--------|------|--------|--------------|
| POST | `/auth` | Validar CPF/CNPJ e gerar JWT | Não |
| OPTIONS | `/auth` | CORS Preflight | Não |

## 📊 Monitoramento

### Métricas CloudWatch Disponíveis
- **Count**: Total de requisições
- **4XXError**: Erros de cliente (bad request)
- **5XXError**: Erros de servidor (Lambda crash)
- **Latency**: Tempo total de resposta
- **IntegrationLatency**: Tempo da Lambda

### Comandos Úteis

**Ver logs em tempo real**:
```bash
aws logs tail /aws/apigateway/valida-pessoa-api-dev --follow
```

**Obter URL da API**:
```bash
terraform output api_gateway_url
```

**Testar endpoint**:
```bash
API_URL=$(terraform output -raw api_gateway_url)
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678901"}'
```

## 🚨 Tratamento de Erros

### Erros da API Gateway
| Status | Causa | Solução |
|--------|-------|---------|
| 400 | Bad Request (JSON inválido) | Validar formato do body |
| 403 | Forbidden (API Key inválida) | N/A (sem API Key neste projeto) |
| 429 | Too Many Requests | Aguardar ou aumentar throttle |
| 500 | Lambda error | Verificar CloudWatch Logs da Lambda |
| 502 | Bad Gateway (Lambda timeout) | Aumentar timeout da Lambda |
| 503 | Service Unavailable | Problema AWS temporário |

### Erros da Lambda (retornados no body)
| Status | Erro | Causa |
|--------|------|-------|
| 400 | "Documento inválido (CPF/CNPJ)" | CPF/CNPJ com formato incorreto |
| 404 | "Pessoa não encontrada" | Documento não existe no banco |
| 403 | "Pessoa com status inativo" | Pessoa existe mas não está ACTIVE |
| 500 | "Erro interno..." | Exception na Lambda ou RDS |

## 🔄 Redeploy da API

O API Gateway faz redeploy automático quando:
- Recursos mudam (`/auth`)
- Métodos mudam (POST, OPTIONS)
- Integrações mudam (Lambda ARN)

**Trigger configurado**:
```hcl
triggers = {
  redeployment = sha1(jsonencode([
    aws_api_gateway_resource.auth.id,
    aws_api_gateway_method.auth_post.id,
    aws_api_gateway_integration.lambda_integration.id,
    ...
  ]))
}
```

## 💡 Melhorias Futuras

### Para Produção
- [ ] **API Key**: Adicionar autenticação via API Key
- [ ] **WAF**: Configurar AWS WAF para proteção adicional
- [ ] **Custom Domain**: `api.seudominio.com` em vez de `*.execute-api...`
- [ ] **Rate Limiting por IP**: Controle granular
- [ ] **Request Validation**: Validação de schema no API Gateway
- [ ] **Caching**: Cache de respostas (se idempotente)

### Para Observabilidade
- [ ] **CloudWatch Dashboards**: Métricas em tempo real
- [ ] **Alarmes**: Alertas para 5XX > threshold
- [ ] **X-Ray**: Service Map para debug

## 📚 Resumo Executivo

**O que é**: API Gateway REST API que expõe endpoint `/auth` para validação de documentos.

**Como funciona**:
1. Cliente faz POST com CPF/CNPJ
2. API Gateway valida e invoca Lambda
3. Lambda valida documento, busca no RDS, gera JWT
4. API Gateway retorna resposta com token

**Características**:
- ✅ CORS habilitado
- ✅ Throttling configurado (5K burst, 10K/s)
- ✅ Logs estruturados no CloudWatch
- ✅ AWS_PROXY (Lambda controla response)
- ✅ Regional endpoint
- ✅ Redeploy automático

**URL de Acesso**:
```
https://{api-id}.execute-api.us-east-1.amazonaws.com/{stage}/auth
```

**Exemplo de Uso**:
```bash
curl -X POST https://xyz.execute-api.us-east-1.amazonaws.com/dev/auth \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}'
```

**Resposta Sucesso**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "customer": {
    "cpf": "11144477735",
    "status": "ACTIVE"
  }
}
```

---

**Documentação completa**: Veja `infra/terraform/api-gateway.tf` para detalhes de implementação.

