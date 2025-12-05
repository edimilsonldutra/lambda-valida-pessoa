# 🏗️ Diagrama de Componentes

## Visão Geral da Arquitetura

Este documento apresenta a arquitetura completa do sistema Lambda Valida Pessoa, incluindo componentes de nuvem, APIs, banco de dados e monitoramento.

---

## 📊 Diagrama de Componentes - Visão Completa

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CLIENTE / APLICAÇÃO                                 │
│                         (Web App, Mobile, Postman)                               │
└──────────────────────────────────┬──────────────────────────────────────────────┘
                                   │ HTTPS Request
                                   │ POST /auth
                                   │ { "cpf": "11144477735" }
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          AWS CLOUD - us-east-1                                   │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐    │
│  │                      API GATEWAY (REST API)                             │    │
│  │  • Endpoint Regional                                                    │    │
│  │  • CORS configurado                                                     │    │
│  │  • Throttling: 10000 req/s                                              │    │
│  │  • Resource: /auth                                                      │    │
│  │  • Methods: POST, OPTIONS                                               │    │
│  └─────────────────────┬──────────────────────────────────────────────────┘    │
│                        │ Proxy Integration                                      │
│                        ▼                                                         │
│  ┌────────────────────────────────────────────────────────────────────────┐    │
│  │                   AWS LAMBDA FUNCTION                                   │    │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │    │
│  │  │  ValidaPessoaFunction (Java 21)                                  │  │    │
│  │  │  • Runtime: Java 21 (Corretto)                                    │  │    │
│  │  │  • Memory: 512 MB                                                 │  │    │
│  │  │  • Timeout: 30s                                                   │  │    │
│  │  │  • VPC Enabled                                                    │  │    │
│  │  │                                                                    │  │    │
│  │  │  Componentes Internos:                                            │  │    │
│  │  │  ┌────────────────────────────────────────────────────────────┐  │  │    │
│  │  │  │  1. DocumentoValidator                                      │  │  │    │
│  │  │  │     - Validação de CPF (algoritmo de dígitos)              │  │  │    │
│  │  │  │     - Validação de CNPJ                                     │  │  │    │
│  │  │  └────────────────────────────────────────────────────────────┘  │  │    │
│  │  │  ┌────────────────────────────────────────────────────────────┐  │  │    │
│  │  │  │  2. CustomerService                                         │  │  │    │
│  │  │  │     - Conexão com RDS PostgreSQL                           │  │  │    │
│  │  │  │     - Query: SELECT * FROM pessoas WHERE documento = ?     │  │  │    │
│  │  │  │     - Verificação de status ACTIVE                         │  │  │    │
│  │  │  └────────────────────────────────────────────────────────────┘  │  │    │
│  │  │  ┌────────────────────────────────────────────────────────────┐  │  │    │
│  │  │  │  3. JWTService                                              │  │  │    │
│  │  │  │     - Geração de JWT (HS256)                               │  │  │    │
│  │  │  │     - Claims: cpf, name, email, status                     │  │  │    │
│  │  │  │     - Expiração: 1 hora                                    │  │  │    │
│  │  │  └────────────────────────────────────────────────────────────┘  │  │    │
│  │  │  ┌────────────────────────────────────────────────────────────┐  │  │    │
│  │  │  │  4. MetricsCollector & StructuredLogger                    │  │  │    │
│  │  │  │     - CloudWatch Metrics (custom)                          │  │  │    │
│  │  │  │     - JSON structured logs                                 │  │  │    │
│  │  │  └────────────────────────────────────────────────────────────┘  │  │    │
│  │  └──────────────────────────────────────────────────────────────────┘  │    │
│  └──────────────┬───────────────────────┬──────────────────────────────────┘    │
│                 │                       │                                        │
│                 │ VPC Connection        │ Logs & Metrics                         │
│                 ▼                       ▼                                        │
│  ┌──────────────────────────┐  ┌──────────────────────────────────────────┐    │
│  │   VPC (10.0.0.0/16)      │  │      CLOUDWATCH                           │    │
│  │                          │  │  ┌─────────────────────────────────────┐  │    │
│  │  ┌──────────────────┐    │  │  │  Log Groups                          │  │    │
│  │  │ Public Subnets   │    │  │  │  /aws/lambda/valida-pessoa-dev       │  │    │
│  │  │ 10.0.1.0/24      │    │  │  │  • Retention: 7 days                 │  │    │
│  │  │ 10.0.2.0/24      │    │  │  │  • Format: JSON structured           │  │    │
│  │  │ (NAT Gateway)    │    │  │  └─────────────────────────────────────┘  │    │
│  │  └──────────────────┘    │  │  ┌─────────────────────────────────────┐  │    │
│  │                          │  │  │  Custom Metrics                      │  │    │
│  │  ┌──────────────────┐    │  │  │  • ValidationSuccess/Failure         │  │    │
│  │  │ Private Subnets  │    │  │  │  • DatabaseQueryDuration             │  │    │
│  │  │ 10.0.11.0/24     │◄───┼──┼──┤  • JWTGenerationDuration             │  │    │
│  │  │ 10.0.12.0/24     │    │  │  │  • SuccessfulAuth                    │  │    │
│  │  │ (Lambda + RDS)   │    │  │  │  • CustomerNotFound                  │  │    │
│  │  └───────┬──────────┘    │  │  └─────────────────────────────────────┘  │    │
│  └──────────┼───────────────┘  │  ┌─────────────────────────────────────┐  │    │
│             │                  │  │  Alarms                              │  │    │
│             │                  │  │  • Lambda Errors > 5                 │  │    │
│             │                  │  │  • Duration > 80% timeout            │  │    │
│             ▼                  │  └─────────────────────────────────────┘  │    │
│  ┌──────────────────────────┐  └──────────────────────────────────────────┘    │
│  │   RDS PostgreSQL 16      │                                                   │
│  │  ┌────────────────────┐  │  ┌──────────────────────────────────────────┐    │
│  │  │  Instance:         │  │  │   AWS SECRETS MANAGER                     │    │
│  │  │  db.t3.micro       │  │  │  ┌─────────────────────────────────────┐  │    │
│  │  │  Storage: 20 GB    │  │  │  │  Secret: db-credentials              │  │    │
│  │  │  Multi-AZ: false   │  │  │  │  {                                   │  │    │
│  │  │  Encrypted: true   │  │  │  │    "username": "postgres",           │  │    │
│  │  │                    │◄─┼──┼──┤    "password": "***",                │  │    │
│  │  │  Database:         │  │  │  │    "host": "rds-endpoint",           │  │    │
│  │  │  • pessoas (table) │  │  │  │    "port": 5432,                     │  │    │
│  │  │  • Indexes: 3      │  │  │  │    "dbname": "validapessoa"          │  │    │
│  │  │  • Constraints: 3  │  │  │  │  }                                   │  │    │
│  │  └────────────────────┘  │  │  └─────────────────────────────────────┘  │    │
│  │                          │  └──────────────────────────────────────────┘    │
│  │  Security Group:         │                                                   │
│  │  • Inbound: 5432         │  ┌──────────────────────────────────────────┐    │
│  │    from Lambda SG        │  │   IAM ROLES & POLICIES                    │    │
│  └──────────────────────────┘  │  • LambdaExecutionRole                    │    │
│                                │    - AWSLambdaVPCAccessExecutionRole      │    │
│                                │    - SecretsManagerReadWrite              │    │
│                                │    - CloudWatchLogsFullAccess             │    │
│                                │    - CloudWatchPutMetricData              │    │
│                                └──────────────────────────────────────────┘    │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐    │
│  │                   NEW RELIC (Opcional - Desativado)                     │    │
│  │  • APM Agent (Java)                                                     │    │
│  │  • Distributed Tracing                                                  │    │
│  │  • Custom Dashboard                                                     │    │
│  │  • 7 Alert Policies                                                     │    │
│  └────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

                                         │
                                         │ Response
                                         ▼
                              ┌─────────────────────┐
                              │  JSON Response:     │
                              │  {                  │
                              │    "token": "eyJ...",│
                              │    "customer": {    │
                              │      "cpf": "...",  │
                              │      "name": "...", │
                              │      "email": "..." │
                              │    }                │
                              │  }                  │
                              └─────────────────────┘
```

---

## 🔍 Detalhamento dos Componentes

### 1. Camada de Apresentação

#### API Gateway
- **Tipo**: REST API Regional
- **Endpoint**: `https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/auth`
- **Recursos**:
  - `/auth` - POST (autenticação)
  - `/auth` - OPTIONS (CORS preflight)
- **Throttling**: 10.000 requests/segundo
- **CORS**: Habilitado para todos os origins (`*`)
- **Integração**: AWS_PROXY com Lambda

**Responsabilidades**:
- Receber requisições HTTP/HTTPS
- Validação de entrada (Content-Type)
- Throttling e rate limiting
- CORS handling
- Roteamento para Lambda

---

### 2. Camada de Aplicação

#### Lambda Function - ValidaPessoaFunction
- **Runtime**: Java 21 (Amazon Corretto)
- **Handler**: `lambdavalida.ValidaPessoaFunction::handleRequest`
- **Configuração**:
  - Memory: 512 MB
  - Timeout: 30 segundos
  - VPC: Habilitado (Private Subnets)
  - Concurrent Executions: 100 (default)

**Componentes Internos**:

1. **DocumentoValidator**
   - Valida CPF usando algoritmo de dígitos verificadores
   - Valida CNPJ (suporte futuro)
   - Rejeita CPFs conhecidos como inválidos

2. **CustomerService**
   - Gerencia conexão com PostgreSQL via JDBC
   - Busca cliente por CPF
   - Verifica status do cliente (ACTIVE/INACTIVE)

3. **JWTService**
   - Gera tokens JWT usando biblioteca jjwt
   - Algoritmo: HS256
   - Claims: cpf, name, email, status
   - Expiração: 1 hora (configurável)

4. **MetricsCollector**
   - Envia métricas customizadas para CloudWatch
   - Métricas: validação, queries, JWT, autenticações

5. **StructuredLogger**
   - Logs em formato JSON
   - Correlation IDs para rastreamento
   - Integração com CloudWatch Logs

**Variáveis de Ambiente**:
```
JWT_SECRET: (secret key 256-bit)
JWT_EXPIRATION_MS: 3600000
ENVIRONMENT: dev
LOG_LEVEL: DEBUG
DB_SECRET_ARN: arn:aws:secretsmanager:...
DB_SCHEMA: public
DB_TABLE: pessoas
```

---

### 3. Camada de Rede

#### VPC Configuration
- **CIDR**: 10.0.0.0/16
- **Subnets Públicas**: 2 (10.0.1.0/24, 10.0.2.0/24)
- **Subnets Privadas**: 2 (10.0.11.0/24, 10.0.12.0/24)
- **Availability Zones**: 2 (us-east-1a, us-east-1b)
- **NAT Gateway**: 1 (subnet pública)
- **Internet Gateway**: 1

**Security Groups**:

1. **Lambda SG**
   - Inbound: Nenhum
   - Outbound: All (0.0.0.0/0)

2. **RDS SG**
   - Inbound: TCP 5432 from Lambda SG
   - Outbound: All

**Fluxo de Rede**:
```
Internet → IGW → API Gateway → Lambda (Private Subnet)
                                  ↓
                            NAT Gateway → Internet
                                  ↓
                            RDS (Private Subnet)
```

---

### 4. Camada de Dados

#### RDS PostgreSQL
- **Engine**: PostgreSQL 16.1
- **Instance Class**: db.t3.micro
- **Storage**: 20 GB (gp3, encrypted)
- **Multi-AZ**: Desabilitado (dev)
- **Backup**: 7 dias de retenção
- **Subnet Group**: Private subnets em 2 AZs

**Tabelas**:
- `pessoas` - Armazena dados de clientes

**Performance Insights**: Desabilitado (dev), habilitado em prod

---

### 5. Camada de Segurança

#### AWS Secrets Manager
- **Secret**: `valida-pessoa-dev-db-credentials`
- **Rotation**: Desabilitado (pode ser habilitado)
- **Conteúdo**:
  ```json
  {
    "username": "postgres",
    "password": "generated-password",
    "host": "rds-endpoint.us-east-1.rds.amazonaws.com",
    "port": 5432,
    "dbname": "validapessoa"
  }
  ```

#### IAM Roles
**LambdaExecutionRole**:
- `AWSLambdaVPCAccessExecutionRole` - VPC networking
- `CloudWatchLogsFullAccess` - Logs
- `SecretsManagerReadWrite` - Acesso a secrets
- Custom policy para CloudWatch Metrics

---

### 6. Camada de Observabilidade

#### CloudWatch
**Log Groups**:
- `/aws/lambda/valida-pessoa-dev`
- Retention: 7 dias
- Format: JSON estruturado

**Custom Metrics**:
- `ValidationSuccess`
- `ValidationFailure`
- `DatabaseQueryDuration`
- `JWTGenerationDuration`
- `SuccessfulAuth`
- `CustomerNotFound`
- `ErrorCount`

**Alarms**:
- Lambda Errors > 5 em 5 minutos
- Duration > 80% do timeout (24s)

#### New Relic (Opcional)
- APM Java Agent
- Distributed Tracing
- Custom Dashboard
- Alert Policies: 7 configurados

---

## 📈 Fluxo de Dados

### Requisição de Autenticação

```
1. Cliente → API Gateway
   POST /auth
   {
     "cpf": "11144477735"
   }

2. API Gateway → Lambda
   Proxy Integration (event completo)

3. Lambda:
   a. Valida CPF (DocumentoValidator)
   b. Consulta cliente (CustomerService → RDS)
   c. Verifica status ACTIVE
   d. Gera JWT (JWTService)
   e. Registra métricas (MetricsCollector)
   f. Log estruturado (StructuredLogger)

4. Lambda → API Gateway
   {
     "statusCode": 200,
     "headers": {...},
     "body": "{\"token\":\"...\",\"customer\":{...}}"
   }

5. API Gateway → Cliente
   200 OK
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

## 🔐 Camadas de Segurança

```
┌─────────────────────────────────────────┐
│  1. API Gateway                          │
│     - HTTPS obrigatório                  │
│     - Throttling configurado             │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  2. Lambda (Execution Role)              │
│     - IAM least privilege                │
│     - Sem acesso público direto          │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  3. VPC (Private Subnets)                │
│     - Lambda isolado em subnet privada   │
│     - Security Groups restritivos        │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  4. Secrets Manager                      │
│     - Credenciais criptografadas         │
│     - Acesso via IAM                     │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  5. RDS (Private Subnet)                 │
│     - Sem acesso público                 │
│     - Encryption at rest                 │
│     - SG aceita apenas Lambda SG         │
└─────────────────────────────────────────┘
```

---

## 📊 Escalabilidade e Performance

### Escalabilidade Automática

| Componente | Escala | Limite |
|------------|--------|--------|
| API Gateway | Automática | 10.000 req/s (padrão) |
| Lambda | Automática | 100 concurrent (padrão) |
| RDS | Manual | Vertical scaling |

### Performance Esperada

| Métrica | Desenvolvimento | Produção |
|---------|----------------|----------|
| **Cold Start** | 1-2s | 1-2s |
| **Warm Response** | 100-200ms | 100-200ms |
| **Database Query** | 20-50ms | 10-30ms |
| **JWT Generation** | 5-10ms | 5-10ms |

---

## 💰 Custos Estimados (Mensal)

| Serviço | Configuração | Custo Estimado |
|---------|--------------|----------------|
| Lambda | 1M requests, 512MB | ~$5 |
| API Gateway | 1M requests | ~$4 |
| RDS | db.t3.micro, 20GB | ~$25 |
| VPC (NAT Gateway) | 1 gateway | ~$32 |
| Secrets Manager | 1 secret | ~$0.40 |
| CloudWatch | Logs + métricas | ~$5 |
| **Total** | - | **~$71** |

---

## 🔄 Alta Disponibilidade

### Componentes com HA

✅ **API Gateway**: Multi-AZ por padrão  
✅ **Lambda**: Multi-AZ por padrão  
⏸️ **RDS**: Multi-AZ desabilitado (dev), habilitado em prod  
✅ **Secrets Manager**: Multi-AZ por padrão  

### SLA Esperado

- **API Gateway**: 99.95%
- **Lambda**: 99.95%
- **RDS Multi-AZ**: 99.95%
- **SLA Combinado**: ~99.85%

---

## 📝 Notas de Implementação

1. **VPC Endpoints**: Podem ser adicionados para Secrets Manager e CloudWatch para reduzir custos de NAT Gateway

2. **Lambda Layers**: New Relic layer é condicional (habilitado via variável)

3. **Database Connection Pooling**: Não implementado (pode usar RDS Proxy)

4. **Caching**: Não implementado (pode usar API Gateway caching ou ElastiCache)

5. **WAF**: Não implementado (pode ser adicionado ao API Gateway)

---

**Última Atualização**: 2025-12-04  
**Versão**: 1.0.0

