# 🔄 Diagrama de Sequência - Fluxo de Autenticação

## Visão Geral

Este documento detalha o fluxo completo de autenticação via CPF, desde a requisição do cliente até a geração do token JWT.

---

## 📊 Diagrama de Sequência - Autenticação Bem-Sucedida

```
┌─────────┐   ┌─────────────┐   ┌──────────────┐   ┌─────────────┐   ┌──────────────┐   ┌────────────┐
│ Cliente │   │ API Gateway │   │    Lambda    │   │ Secrets Mgr │   │ RDS Postgres │   │ CloudWatch │
└────┬────┘   └──────┬──────┘   └──────┬───────┘   └──────┬──────┘   └──────┬───────┘   └─────┬──────┘
     │               │                  │                  │                  │                 │
     │ 1. POST /auth │                  │                  │                  │                 │
     │ {"cpf":"111"} │                  │                  │                  │                 │
     ├──────────────>│                  │                  │                  │                 │
     │               │                  │                  │                  │                 │
     │               │ 2. Invoke Lambda │                  │                  │                 │
     │               │ (Proxy Event)    │                  │                  │                 │
     │               ├─────────────────>│                  │                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 3. Log Request   │                  │                 │
     │               │                  │ Started          │                  │                 │
     │               │                  ├──────────────────────────────────────────────────────>│
     │               │                  │                  │                  │                 │
     │               │                  │ 4. Parse Body    │                  │                 │
     │               │                  │ (AuthRequest)    │                  │                 │
     │               │                  ├─┐                │                  │                 │
     │               │                  │ │                │                  │                 │
     │               │                  │<┘                │                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 5. Validate CPF  │                  │                 │
     │               │                  │ (DocumentoValidator)                │                 │
     │               │                  ├─┐                │                  │                 │
     │               │                  │ │ • Remove mask  │                  │                 │
     │               │                  │ │ • Check length │                  │                 │
     │               │                  │ │ • Calc digit 1 │                  │                 │
     │               │                  │ │ • Calc digit 2 │                  │                 │
     │               │                  │<┘                │                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 6. Log Validation│                  │                 │
     │               │                  │ Success Metric   │                  │                 │
     │               │                  ├──────────────────────────────────────────────────────>│
     │               │                  │                  │                  │                 │
     │               │                  │ 7. Get DB Credentials                │                 │
     │               │                  ├─────────────────>│                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 8. Return Secret │                  │                 │
     │               │                  │ (username/password)                 │                 │
     │               │                  │<─────────────────┤                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 9. Connect to DB │                  │                 │
     │               │                  │ (JDBC)           │                  │                 │
     │               │                  ├──────────────────────────────────────>│                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 10. Query Customer                  │                 │
     │               │                  │ SELECT * FROM pessoas               │                 │
     │               │                  │ WHERE documento = '11144477735'     │                 │
     │               │                  ├──────────────────────────────────────>│                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 11. Return Customer                 │                 │
     │               │                  │ (cpf, name, email, status)          │                 │
     │               │                  │<──────────────────────────────────────┤                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 12. Log DB Query │                  │                 │
     │               │                  │ Duration Metric  │                  │                 │
     │               │                  ├──────────────────────────────────────────────────────>│
     │               │                  │                  │                  │                 │
     │               │                  │ 13. Check Status │                  │                 │
     │               │                  │ (ACTIVE?)        │                  │                 │
     │               │                  ├─┐                │                  │                 │
     │               │                  │ │ if != ACTIVE   │                  │                 │
     │               │                  │ │ → return 403   │                  │                 │
     │               │                  │<┘                │                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 14. Generate JWT │                  │                 │
     │               │                  │ (JWTService)     │                  │                 │
     │               │                  ├─┐                │                  │                 │
     │               │                  │ │ Claims:        │                  │                 │
     │               │                  │ │ - cpf          │                  │                 │
     │               │                  │ │ - name         │                  │                 │
     │               │                  │ │ - email        │                  │                 │
     │               │                  │ │ - status       │                  │                 │
     │               │                  │ │ Sign: HS256    │                  │                 │
     │               │                  │ │ Exp: 1h        │                  │                 │
     │               │                  │<┘                │                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 15. Log JWT      │                  │                 │
     │               │                  │ Generation Metric│                  │                 │
     │               │                  ├──────────────────────────────────────────────────────>│
     │               │                  │                  │                  │                 │
     │               │                  │ 16. Build Response                  │                 │
     │               │                  │ (AuthResponse)   │                  │                 │
     │               │                  ├─┐                │                  │                 │
     │               │                  │ │ {              │                  │                 │
     │               │                  │ │   token: "...",│                  │                 │
     │               │                  │ │   customer: {} │                  │                 │
     │               │                  │ │ }              │                  │                 │
     │               │                  │<┘                │                  │                 │
     │               │                  │                  │                  │                 │
     │               │                  │ 17. Log Success  │                  │                 │
     │               │                  │ Auth Metric      │                  │                 │
     │               │                  ├──────────────────────────────────────────────────────>│
     │               │                  │                  │                  │                 │
     │               │ 18. Return 200   │                  │                  │                 │
     │               │ (API Response)   │                  │                  │                 │
     │               │<─────────────────┤                  │                  │                 │
     │               │                  │                  │                  │                 │
     │ 19. 200 OK    │                  │                  │                  │                 │
     │ {"token":...} │                  │                  │                  │                 │
     │<──────────────┤                  │                  │                  │                 │
     │               │                  │                  │                  │                 │
```

---

## ⏱️ Tempos de Processamento (Típicos)

| Etapa | Duração Típica | Métrica CloudWatch |
|-------|----------------|---------------------|
| **API Gateway → Lambda** | 5-10ms | - |
| **Parse & Validation** | 2-5ms | `ValidationSuccess` |
| **Secrets Manager** | 10-20ms | - |
| **Database Connection** | 50-100ms (cold) | - |
| **Database Query** | 20-50ms | `DatabaseQueryDuration` |
| **JWT Generation** | 5-10ms | `JWTGenerationDuration` |
| **Response Serialization** | 2-5ms | - |
| **Lambda → API Gateway** | 5-10ms | - |
| **TOTAL (Warm)** | **100-200ms** | `Duration` |
| **TOTAL (Cold Start)** | **1-2s** | `Duration` |

---

## 🚫 Diagrama de Sequência - CPF Inválido

```
┌─────────┐   ┌─────────────┐   ┌──────────────┐   ┌────────────┐
│ Cliente │   │ API Gateway │   │    Lambda    │   │ CloudWatch │
└────┬────┘   └──────┬──────┘   └──────┬───────┘   └─────┬──────┘
     │               │                  │                 │
     │ 1. POST /auth │                  │                 │
     │ {"cpf":"123"} │                  │                 │
     ├──────────────>│                  │                 │
     │               │                  │                 │
     │               │ 2. Invoke Lambda │                 │
     │               ├─────────────────>│                 │
     │               │                  │                 │
     │               │                  │ 3. Parse Body   │
     │               │                  ├─┐               │
     │               │                  │<┘               │
     │               │                  │                 │
     │               │                  │ 4. Validate CPF │
     │               │                  ├─┐               │
     │               │                  │ │ INVALID!      │
     │               │                  │<┘               │
     │               │                  │                 │
     │               │                  │ 5. Log Validation│
     │               │                  │ Failure Metric  │
     │               │                  ├────────────────>│
     │               │                  │                 │
     │               │ 6. Return 400    │                 │
     │               │ {"error":"CPF    │                 │
     │               │  inválido"}      │                 │
     │               │<─────────────────┤                 │
     │               │                  │                 │
     │ 7. 400 Error  │                  │                 │
     │<──────────────┤                  │                 │
     │               │                  │                 │
```

**Duração**: ~10-20ms (fail fast)

---

## ❌ Diagrama de Sequência - Cliente Não Encontrado

```
┌─────────┐   ┌─────────────┐   ┌──────────────┐   ┌──────────────┐   ┌────────────┐
│ Cliente │   │ API Gateway │   │    Lambda    │   │ RDS Postgres │   │ CloudWatch │
└────┬────┘   └──────┬──────┘   └──────┬───────┘   └──────┬───────┘   └─────┬──────┘
     │               │                  │                  │                 │
     │ 1. POST /auth │                  │                  │                 │
     │ {"cpf":"999"} │                  │                  │                 │
     ├──────────────>│                  │                  │                 │
     │               │                  │                  │                 │
     │               │ 2. Invoke Lambda │                  │                 │
     │               ├─────────────────>│                  │                 │
     │               │                  │                  │                 │
     │               │                  │ 3-6. Validate OK │                 │
     │               │                  │ (steps omitted)  │                 │
     │               │                  │                  │                 │
     │               │                  │ 7. Query Customer│                 │
     │               │                  ├─────────────────>│                 │
     │               │                  │                  │                 │
     │               │                  │ 8. Return NULL   │                 │
     │               │                  │ (not found)      │                 │
     │               │                  │<─────────────────┤                 │
     │               │                  │                  │                 │
     │               │                  │ 9. Log Customer  │                 │
     │               │                  │ Not Found Metric │                 │
     │               │                  ├─────────────────────────────────────>│
     │               │                  │                  │                 │
     │               │ 10. Return 404   │                  │                 │
     │               │ {"error":"Cliente│                  │                 │
     │               │  não encontrado"}│                  │                 │
     │               │<─────────────────┤                  │                 │
     │               │                  │                  │                 │
     │ 11. 404 Error │                  │                  │                 │
     │<──────────────┤                  │                  │                 │
     │               │                  │                  │                 │
```

**Duração**: ~100-150ms

---

## 🔒 Diagrama de Sequência - Cliente Inativo

```
┌─────────┐   ┌─────────────┐   ┌──────────────┐   ┌──────────────┐   ┌────────────┐
│ Cliente │   │ API Gateway │   │    Lambda    │   │ RDS Postgres │   │ CloudWatch │
└────┬────┘   └──────┬──────┘   └──────┬───────┘   └──────┬───────┘   └─────┬──────┘
     │               │                  │                  │                 │
     │ 1. POST /auth │                  │                  │                 │
     ├──────────────>│                  │                  │                 │
     │               │                  │                  │                 │
     │               │ 2. Invoke Lambda │                  │                 │
     │               ├─────────────────>│                  │                 │
     │               │                  │                  │                 │
     │               │                  │ 3-8. Query OK    │                 │
     │               │                  │ (steps omitted)  │                 │
     │               │                  │<─────────────────┤                 │
     │               │                  │                  │                 │
     │               │                  │ 9. Check Status  │                 │
     │               │                  ├─┐                │                 │
     │               │                  │ │ status=INACTIVE│                 │
     │               │                  │<┘                │                 │
     │               │                  │                  │                 │
     │               │                  │ 10. Log Inactive │                 │
     │               │                  │ Customer Metric  │                 │
     │               │                  ├─────────────────────────────────────>│
     │               │                  │                  │                 │
     │               │ 11. Return 403   │                  │                 │
     │               │ {"error":"Cliente│                  │                 │
     │               │  inativo"}       │                  │                 │
     │               │<─────────────────┤                  │                 │
     │               │                  │                  │                 │
     │ 12. 403 Error │                  │                  │                 │
     │<──────────────┤                  │                  │                 │
     │               │                  │                  │                 │
```

**Duração**: ~100-150ms

---

## 💥 Diagrama de Sequência - Erro Interno

```
┌─────────┐   ┌─────────────┐   ┌──────────────┐   ┌────────────┐   ┌──────────┐
│ Cliente │   │ API Gateway │   │    Lambda    │   │ CloudWatch │   │ New Relic│
└────┬────┘   └──────┬──────┘   └──────┬───────┘   └─────┬──────┘   └────┬─────┘
     │               │                  │                 │                │
     │ 1. POST /auth │                  │                 │                │
     ├──────────────>│                  │                 │                │
     │               │                  │                 │                │
     │               │ 2. Invoke Lambda │                 │                │
     │               ├─────────────────>│                 │                │
     │               │                  │                 │                │
     │               │                  │ 3. Processing...│                │
     │               │                  ├─┐               │                │
     │               │                  │ │ Exception!    │                │
     │               │                  │ │ (DB timeout,  │                │
     │               │                  │ │  etc.)        │                │
     │               │                  │<┘               │                │
     │               │                  │                 │                │
     │               │                  │ 4. Log Error    │                │
     │               │                  ├────────────────>│                │
     │               │                  │                 │                │
     │               │                  │ 5. Notice Error │                │
     │               │                  ├─────────────────────────────────>│
     │               │                  │                 │                │
     │               │                  │ 6. Record Error │                │
     │               │                  │ Count Metric    │                │
     │               │                  ├────────────────>│                │
     │               │                  │                 │                │
     │               │ 7. Return 500    │                 │                │
     │               │ {"error":"Erro   │                 │                │
     │               │  interno"}       │                 │                │
     │               │<─────────────────┤                 │                │
     │               │                  │                 │                │
     │ 8. 500 Error  │                  │                 │                │
     │<──────────────┤                  │                 │                │
     │               │                  │                 │                │
```

**Duração**: Variável (depende do tipo de erro)

---

## 📊 Detalhamento das Etapas

### Fase 1: Recebimento e Validação (Etapas 1-6)

#### 1. Cliente → API Gateway
- **Input**: 
  ```json
  POST /auth
  Content-Type: application/json
  
  {
    "cpf": "11144477735"
  }
  ```
- **Validações do API Gateway**:
  - Content-Type header presente
  - Body não vazio
  - Rate limiting (10.000 req/s)

#### 2. API Gateway → Lambda
- **Integração**: AWS_PROXY
- **Event Structure**:
  ```json
  {
    "httpMethod": "POST",
    "path": "/auth",
    "headers": {...},
    "body": "{\"cpf\":\"11144477735\"}",
    "requestContext": {...}
  }
  ```

#### 3. Lambda: Logging Inicial
- **Correlation ID**: Gerado (UUID)
- **Request ID**: AWS fornecido
- **Log Entry**:
  ```json
  {
    "level": "INFO",
    "message": "auth_request_started",
    "correlationId": "uuid-123",
    "requestId": "aws-request-id",
    "timestamp": "2025-12-04T10:00:00Z"
  }
  ```

#### 4. Lambda: Parse do Body
- **Desserialização**: Jackson ObjectMapper
- **Validação**: Campos obrigatórios
- **Modelo**:
  ```java
  class AuthRequest {
      private String cpf; // required
  }
  ```

#### 5. Lambda: Validação de CPF
- **Algoritmo**:
  1. Remove caracteres não numéricos
  2. Verifica tamanho = 11
  3. Rejeita sequências repetidas (111.111.111-11)
  4. Calcula primeiro dígito verificador
  5. Calcula segundo dígito verificador
  6. Compara com CPF fornecido

- **Pseudocódigo**:
  ```
  cpf = "11144477735"
  digits = cpf[0..8]
  
  // Primeiro dígito
  sum = Σ(digits[i] * (10-i)) for i=0 to 8
  digit1 = 11 - (sum % 11)
  if digit1 >= 10: digit1 = 0
  
  // Segundo dígito
  sum = Σ(digits[i] * (11-i)) for i=0 to 9
  digit2 = 11 - (sum % 11)
  if digit2 >= 10: digit2 = 0
  
  valid = (cpf[9] == digit1) && (cpf[10] == digit2)
  ```

#### 6. Lambda: Métrica de Validação
- **Métrica**: `ValidationSuccess`
- **Namespace**: Custom/ValidaPessoa
- **Dimensões**: Environment=dev
- **Valor**: Duration (ms)

---

### Fase 2: Consulta ao Banco (Etapas 7-12)

#### 7. Lambda → Secrets Manager
- **API Call**: `GetSecretValue`
- **Secret ARN**: `arn:aws:secretsmanager:us-east-1:...:secret:db-creds`
- **Cache**: Pode ser implementado para reduzir calls

#### 8. Secrets Manager → Lambda
- **Response**:
  ```json
  {
    "username": "postgres",
    "password": "encrypted-password",
    "host": "rds-endpoint.rds.amazonaws.com",
    "port": 5432,
    "dbname": "validapessoa"
  }
  ```

#### 9. Lambda → RDS: Conexão
- **Driver**: PostgreSQL JDBC
- **Connection String**: 
  ```
  jdbc:postgresql://host:5432/dbname?ssl=true
  ```
- **Pool**: Single connection (pode usar HikariCP)

#### 10. Lambda → RDS: Query
- **SQL**:
  ```sql
  SELECT cpf, name, email, status 
  FROM pessoas 
  WHERE documento = ?
  LIMIT 1
  ```
- **Prepared Statement**: Sim (proteção SQL injection)
- **Index Used**: `idx_pessoas_documento` (UNIQUE)

#### 11. RDS → Lambda: Resultado
- **ResultSet**:
  ```java
  Customer {
      cpf: "11144477735",
      name: "João Silva",
      email: "joao@example.com",
      status: "ACTIVE"
  }
  ```

#### 12. Lambda: Métrica de DB
- **Métrica**: `DatabaseQueryDuration`
- **Valor**: Query execution time (ms)

---

### Fase 3: Geração do Token (Etapas 13-17)

#### 13. Lambda: Verificação de Status
- **Condição**: `customer.status == "ACTIVE"`
- **Se INACTIVE**: Return 403 Forbidden
- **Se ACTIVE**: Continuar para JWT

#### 14. Lambda: Geração de JWT
- **Biblioteca**: jjwt (io.jsonwebtoken)
- **Algoritmo**: HS256 (HMAC SHA-256)
- **Secret**: 256-bit key do environment
- **Claims**:
  ```json
  {
    "sub": "11144477735",
    "cpf": "11144477735",
    "name": "João Silva",
    "email": "joao@example.com",
    "status": "ACTIVE",
    "iat": 1701684000,
    "exp": 1701687600
  }
  ```
- **Expiração**: 1 hora (3600 segundos)

- **Código**:
  ```java
  String token = Jwts.builder()
      .subject(customer.getCpf())
      .claim("cpf", customer.getCpf())
      .claim("name", customer.getName())
      .claim("email", customer.getEmail())
      .claim("status", customer.getStatus())
      .issuedAt(Date.from(now))
      .expiration(Date.from(now.plus(1, ChronoUnit.HOURS)))
      .signWith(key)
      .compact();
  ```

#### 15. Lambda: Métrica de JWT
- **Métrica**: `JWTGenerationDuration`
- **Valor**: Generation time (ms)

#### 16. Lambda: Construção da Resposta
- **Modelo**:
  ```java
  class AuthResponse {
      private String token;
      private Customer customer;
  }
  ```
- **JSON**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "customer": {
      "cpf": "11144477735",
      "name": "João Silva",
      "email": "joao@example.com",
      "status": "ACTIVE"
    }
  }
  ```

#### 17. Lambda: Métrica de Sucesso
- **Métrica**: `SuccessfulAuth`
- **Dimensões**: Environment=dev
- **Valor**: Total duration (ms)

---

### Fase 4: Resposta ao Cliente (Etapas 18-19)

#### 18. Lambda → API Gateway
- **Response Structure**:
  ```json
  {
    "statusCode": 200,
    "headers": {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    },
    "body": "{\"token\":\"...\",\"customer\":{...}}"
  }
  ```

#### 19. API Gateway → Cliente
- **HTTP Response**:
  ```
  HTTP/1.1 200 OK
  Content-Type: application/json
  Access-Control-Allow-Origin: *
  
  {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "customer": {
      "cpf": "11144477735",
      "name": "João Silva",
      "email": "joao@example.com",
      "status": "ACTIVE"
    }
  }
  ```

---

## 🔍 Observabilidade

### Logs Gerados (CloudWatch)

```json
[
  {
    "level": "INFO",
    "message": "auth_request_started",
    "correlationId": "uuid-123",
    "requestId": "aws-req-456",
    "timestamp": "2025-12-04T10:00:00.000Z"
  },
  {
    "level": "INFO",
    "message": "cpf_validation_success",
    "correlationId": "uuid-123",
    "duration_ms": 3
  },
  {
    "level": "INFO",
    "message": "database_query_completed",
    "correlationId": "uuid-123",
    "duration_ms": 45
  },
  {
    "level": "INFO",
    "message": "jwt_generated",
    "correlationId": "uuid-123",
    "duration_ms": 8
  },
  {
    "level": "INFO",
    "message": "auth_successful",
    "correlationId": "uuid-123",
    "total_duration_ms": 156
  }
]
```

### Métricas Registradas (CloudWatch)

| Métrica | Valor | Timestamp |
|---------|-------|-----------|
| `ValidationSuccess` | 3ms | 10:00:00.003 |
| `DatabaseQueryDuration` | 45ms | 10:00:00.048 |
| `JWTGenerationDuration` | 8ms | 10:00:00.056 |
| `SuccessfulAuth` | 156ms | 10:00:00.156 |

### Traces (New Relic - Opcional)

```
Transaction: POST /auth
├─ Span: handleRequest (156ms)
│  ├─ Span: validateCPF (3ms)
│  ├─ Span: getSecretValue (15ms)
│  ├─ Span: queryDatabase (45ms)
│  └─ Span: generateJWT (8ms)
```

---

## 📈 Cenários de Performance

### Cenário 1: First Invocation (Cold Start)
```
Total: ~1.5 - 2.0 segundos
├─ Lambda Init: 1000-1500ms
├─ Processing: 150-200ms
└─ Network: 50ms
```

### Cenário 2: Warm Invocation
```
Total: ~150 - 200ms
├─ Validation: 3ms
├─ Secrets: 15ms
├─ DB Query: 45ms
├─ JWT Gen: 8ms
├─ Response: 5ms
└─ Network: 74ms
```

### Cenário 3: High Load (100 concurrent)
```
Total: ~150 - 300ms
├─ Processing: 150-200ms
├─ DB Queuing: 0-50ms
└─ Lambda Throttling: 0 (dentro do limite)
```

---

**Última Atualização**: 2025-12-04  
**Versão**: 1.0.0

