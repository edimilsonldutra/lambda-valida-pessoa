# RFC-002: Escolha do Banco de Dados

**Status**: ✅ APROVADO  
**Data**: 2025-11-18  
**Autor**: Equipe FIAP - Fase 3  
**Decisão**: PostgreSQL RDS (Relacional Gerenciado)

---

## 📋 Sumário Executivo

Este RFC documenta a análise e decisão sobre a escolha do banco de dados para o sistema Lambda Valida Pessoa. Após avaliação de três opções (RDS PostgreSQL, DynamoDB e Aurora Serverless), decidiu-se pelo **PostgreSQL RDS**.

---

## 🎯 Contexto e Problema

### Requisitos de Dados

1. **Modelo de Dados**:
   - Entidade principal: `pessoas` (clientes)
   - Relacionamentos: Planejado para futuro (endereços, logs)
   - Queries: Principalmente por CPF/CNPJ (chave única)

2. **Volume**:
   - Inicial: ~1.000 registros
   - 1 ano: ~50.000 registros
   - 5 anos: ~500.000 registros

3. **Padrão de Acesso**:
   - 90% reads, 10% writes
   - Queries simples: SELECT por documento
   - Transações: Não críticas
   - Latência: <50ms desejável

4. **Consistência**:
   - ACID desejável (mas não crítico)
   - Eventual consistency aceitável para alguns casos

---

## 🔍 Análise Comparativa

### Opção 1: RDS PostgreSQL ✅ ESCOLHIDA

#### Descrição
Banco de dados relacional PostgreSQL gerenciado pela AWS.

#### Configuração Proposta
- **Instance**: db.t3.micro (2 vCPU, 1GB RAM)
- **Storage**: 20GB gp3 (SSD)
- **Engine**: PostgreSQL 16
- **Multi-AZ**: Desabilitado (dev), habilitado (prod)
- **Backup**: 7 dias de retenção

#### Vantagens ✅

1. **Familiaridade**:
   - PostgreSQL é amplamente conhecido
   - SQL padrão, fácil de aprender
   - Ferramentas maduras (pgAdmin, DBeaver)

2. **Modelo Relacional**:
   - Suporta JOINs complexos (útil para extensões futuras)
   - Constraints (UNIQUE, CHECK, FK) garantem integridade
   - Normalização facilita manutenção

3. **Extensibilidade**:
   - Fácil adicionar colunas/tabelas
   - Suporta JSON para dados semi-estruturados
   - Índices B-Tree eficientes

4. **Ferramentas de Desenvolvimento**:
   - Migrações com Flyway/Liquibase
   - ORMs maduros (Hibernate, JPA)
   - Geração de schemas automática

5. **Backup e Recovery**:
   - Snapshots automáticos
   - Point-in-time recovery
   - Restore para qualquer momento nos últimos 7 dias

6. **Integração Lambda**:
   - JDBC nativo (driver PostgreSQL)
   - VPC permite conexão segura
   - Connection pooling possível (HikariCP)

#### Desvantagens ❌

1. **Custo Fixo**:
   - Instance sempre rodando (~$25/mês)
   - Mesmo sem uso, há custo
   - NAT Gateway adiciona $32/mês

2. **Escalabilidade Vertical**:
   - Escala apenas verticalmente (instâncias maiores)
   - Downtime para resize (alguns minutos)

3. **Connection Limits**:
   - db.t3.micro: ~87 conexões simultâneas
   - Lambda pode esgotar pool (necessita RDS Proxy)

4. **Latência VPC**:
   - Lambda em VPC tem cold start maior (~1-2s)
   - Conexão DB adiciona 20-50ms

#### Custo Mensal
- **Instance**: $16 (db.t3.micro, 730h)
- **Storage**: $2.30 (20GB gp3)
- **Backup**: $2 (20GB, 7 dias)
- **Multi-AZ** (prod): +$16
- **Total Dev**: $20.30
- **Total Prod**: $36.30

---

### Opção 2: DynamoDB

#### Descrição
Banco NoSQL totalmente gerenciado, serverless.

#### Configuração Proposta
- **Tabela**: `pessoas`
- **Partition Key**: `documento` (CPF/CNPJ)
- **Billing**: On-Demand
- **Indexes**: GSI para perfil/cargo (se necessário)

#### Vantagens ✅

1. **Serverless Nativo**:
   - Escala automaticamente
   - Pay-per-request (sem custo fixo)
   - Zero administração

2. **Performance**:
   - Latência single-digit milliseconds (<10ms)
   - Throughput ilimitado (com custo)

3. **Alta Disponibilidade**:
   - Multi-AZ por padrão
   - SLA 99.99%
   - Backup contínuo (PITR)

4. **Integração Lambda**:
   - SDK nativo AWS
   - Sem necessidade de VPC
   - Cold start menor (~500ms)

5. **Custo Inicial Baixo**:
   - Free tier: 25GB storage, 25 read/write units
   - On-demand: paga apenas o que usa

#### Desvantagens ❌

1. **Modelo NoSQL**:
   - Sem JOINs nativos
   - Queries limitadas (apenas por chaves)
   - Denormalização necessária

2. **Curva de Aprendizado**:
   - Paradigma diferente de SQL
   - Design de chaves é crítico
   - Erros de design são custosos para corrigir

3. **Queries Complexas**:
   - Busca por múltiplos atributos requer GSI (custo adicional)
   - Scans são caros e lentos

4. **Custo Imprevisível**:
   - On-demand pode ter picos de custo
   - GSI duplica storage cost
   - Leituras/escritas acumulam rapidamente

5. **Limitações**:
   - Item máximo: 400KB
   - Transações: Até 100 items
   - Eventual consistency por padrão

#### Custo Mensal (Estimado)
- **Storage**: $0.25 (1GB)
- **Reads**: $2.50 (1M reads on-demand)
- **Writes**: $12.50 (100K writes on-demand)
- **GSI** (opcional): +$0.25 storage, +$2.50 reads
- **Total**: $15.25 - $18.00

**Observação**: Pode ser mais barato inicialmente, mas custo cresce com uso.

---

### Opção 3: Aurora Serverless v2

#### Descrição
PostgreSQL compatível, serverless, auto-scaling.

#### Configuração Proposta
- **Engine**: Aurora PostgreSQL 15
- **Capacity**: 0.5 - 2 ACUs (Aurora Capacity Units)
- **Storage**: Auto-scaling

#### Vantagens ✅

1. **Serverless**:
   - Escala automaticamente (0.5 - 128 ACUs)
   - Pausa automática após inatividade (Aurora v1)
   - Pay-per-second

2. **Performance**:
   - 3x mais rápido que PostgreSQL padrão
   - Storage distribuído, alta performance

3. **Compatibilidade**:
   - 100% compatível com PostgreSQL
   - Mesmo código que RDS PostgreSQL

4. **Alta Disponibilidade**:
   - Multi-AZ por padrão
   - Failover < 30 segundos

#### Desvantagens ❌

1. **Custo MUITO Maior**:
   - Aurora Serverless v2: $0.12/ACU-hour
   - Mínimo 0.5 ACU = $43.80/mês (0.5 ACU * 730h * $0.12)
   - 2x-3x mais caro que RDS para workloads pequenos

2. **Complexidade**:
   - Configuração mais complexa que RDS
   - Tuning de ACUs requer experiência

3. **Custo de Storage**:
   - $0.10/GB (vs $0.115/GB RDS gp3)
   - I/O adicional: $0.20/1M requests

4. **Não Justificável para Projeto**:
   - Overkill para 1M requests/mês
   - Custo-benefício ruim para escala pequena

#### Custo Mensal
- **Compute**: $43.80 (0.5 ACU mínimo)
- **Storage**: $2.00 (20GB)
- **I/O**: $2.00 (10M requests)
- **Total**: $47.80

**Comparado a RDS**: +137% de custo

---

## 📊 Matriz de Decisão

| Critério | Peso | RDS PostgreSQL | DynamoDB | Aurora Serverless |
|----------|------|----------------|----------|-------------------|
| **Custo (dev)** | 25% | 8 | 9 | 3 |
| **Familiaridade** | 20% | 10 | 5 | 9 |
| **Escalabilidade** | 15% | 6 | 10 | 10 |
| **Performance** | 15% | 7 | 10 | 9 |
| **Facilidade** | 10% | 9 | 6 | 7 |
| **Extensibilidade** | 10% | 10 | 5 | 10 |
| **Manutenção** | 5% | 7 | 9 | 8 |
| **TOTAL** | 100% | **8.10** | **7.45** | **7.35** |

---

## ✅ Decisão

### Escolha: **RDS PostgreSQL**

### Justificativa Principal

1. **Custo-Benefício**: Melhor relação custo/benefício para escala atual e projetada

2. **Familiaridade da Equipe**: Conhecimento existente em SQL/PostgreSQL

3. **Modelo Relacional**: Requisitos futuros (relacionamentos) favorecem SQL

4. **Maturidade**: Ferramentas e práticas bem estabelecidas

5. **Previsibilidade**: Custo fixo mensal ($20-40) é previsível e gerenciável

### Trade-offs Aceitos

❌ **Custo Fixo**: Aceitamos pagar ~$20/mês mesmo sem uso  
❌ **Escalabilidade Limitada**: Aceitamos escala vertical (suficiente para 500K registros)  
❌ **Cold Start**: Aceitamos +1s de cold start em Lambda VPC  

✅ **Ganhos**: Simplicidade, familiaridade, extensibilidade, ACID

---

## 🎯 Plano de Implementação

### Fase 1: Setup Inicial
```hcl
# Terraform: RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier        = "valida-pessoa-db"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  
  db_name  = "validapessoa"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  skip_final_snapshot     = false
  
  tags = {
    Environment = "dev"
    Project     = "lambda-valida-pessoa"
  }
}
```

### Fase 2: Schema
```sql
CREATE TABLE pessoas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  documento VARCHAR(14) NOT NULL UNIQUE,
  tipo_pessoa CHAR(1) NOT NULL CHECK (tipo_pessoa IN ('F', 'J')),
  cargo VARCHAR(100) NOT NULL,
  perfil VARCHAR(50) NOT NULL DEFAULT 'PADRAO',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_documento ON pessoas(documento);
CREATE INDEX idx_perfil_cargo ON pessoas(perfil, cargo);
```

### Fase 3: Conexão Lambda
```java
// Lambda: JDBC Connection
String dbUrl = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPass = System.getenv("DB_PASS");

Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
```

---

## 🔄 Plano de Migração Futura

Se o projeto crescer além de 1M registros ou 10.000 req/s:

### Opção A: Aurora Serverless v2
- Migração simples (dump/restore)
- Custo justificável com escala maior
- Zero alteração de código

### Opção B: Read Replicas
- RDS com 1-2 read replicas
- Direcionar reads para replicas
- Writes para master

### Opção C: Híbrido
- PostgreSQL para dados estruturados
- DynamoDB para cache/sessões
- Redis/ElastiCache para hot data

---

## 📚 Referências

- [RDS PostgreSQL Pricing](https://aws.amazon.com/rds/postgresql/pricing/)
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [Aurora Serverless v2 Pricing](https://aws.amazon.com/rds/aurora/pricing/)
- [Lambda + RDS Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/services-rds.html)

---

## 📝 Histórico

| Versão | Data | Mudanças |
|--------|------|----------|
| 1.0 | 2025-11-18 | Versão inicial |
| 2.0 | 2025-12-04 | Implementação completa e validação |

---

**Status**: ✅ IMPLEMENTADO  
**Aprovado por**: Equipe FIAP - Fase 3

