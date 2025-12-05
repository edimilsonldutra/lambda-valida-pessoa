# 📚 Documentação Arquitetural - Lambda Valida Pessoa

Bem-vindo à documentação completa da arquitetura do sistema Lambda Valida Pessoa. Esta documentação foi desenvolvida como parte do projeto FIAP - Fase 3 e contém todos os artefatos arquiteturais, decisões técnicas e justificativas.

---

## 📋 Índice Rápido

| Documento | Descrição | Tipo |
|-----------|-----------|------|
| **[00-INDICE.md](./00-INDICE.md)** | Índice completo de toda documentação | 📑 Navegação |
| **[01-DIAGRAMA-COMPONENTES.md](./01-DIAGRAMA-COMPONENTES.md)** | Arquitetura completa do sistema | 🏗️ Diagrama |
| **[02-DIAGRAMA-SEQUENCIA-AUTH.md](./02-DIAGRAMA-SEQUENCIA-AUTH.md)** | Fluxo de autenticação detalhado | 🔄 Diagrama |
| **[03-DIAGRAMA-ER.md](./03-DIAGRAMA-ER.md)** | Modelo de dados relacional | 📊 Diagrama |
| **[RFC-001-ESCOLHA-CLOUD.md](./RFC-001-ESCOLHA-CLOUD.md)** | AWS vs Azure vs GCP | 📄 RFC |
| **[RFC-002-ESCOLHA-DATABASE.md](./RFC-002-ESCOLHA-DATABASE.md)** | PostgreSQL vs DynamoDB vs Aurora | 📄 RFC |
| **[RFC-003-ESTRATEGIA-AUTENTICACAO.md](./RFC-003-ESTRATEGIA-AUTENTICACAO.md)** | JWT vs Cognito vs Sessions | 📄 RFC |
| **[ADR-001-SERVERLESS-ARCHITECTURE.md](./ADR-001-SERVERLESS-ARCHITECTURE.md)** | Decisão: Arquitetura Serverless | ✅ ADR |
| **[ADR-004-TERRAFORM-IAC.md](./ADR-004-TERRAFORM-IAC.md)** | Decisão: Terraform como IaC | ✅ ADR |
| **[ADR-006-CICD-GITHUB-ACTIONS.md](./ADR-006-CICD-GITHUB-ACTIONS.md)** | Decisão: CI/CD com GitHub Actions | ✅ ADR |
| **[04-JUSTIFICATIVA-POSTGRESQL.md](./04-JUSTIFICATIVA-POSTGRESQL.md)** | Análise detalhada do PostgreSQL | 📊 Justificativa |

---

## 🎯 Guia de Leitura por Perfil

### 👨‍💻 Para Desenvolvedores
**Objetivo**: Entender a arquitetura para contribuir com código

**Leitura Recomendada**:
1. [Diagrama de Componentes](./01-DIAGRAMA-COMPONENTES.md) - Visão geral da arquitetura
2. [Diagrama de Sequência](./02-DIAGRAMA-SEQUENCIA-AUTH.md) - Fluxo de autenticação
3. [Diagrama ER](./03-DIAGRAMA-ER.md) - Modelo de dados
4. [ADR-001 Serverless](./ADR-001-SERVERLESS-ARCHITECTURE.md) - Por quê Lambda?
5. [ADR-006 CI/CD](./ADR-006-CICD-GITHUB-ACTIONS.md) - Como fazer deploy

**Tempo Estimado**: 30-40 minutos

---

### 🏗️ Para Arquitetos
**Objetivo**: Revisar decisões arquiteturais e padrões

**Leitura Recomendada**:
1. [00-INDICE.md](./00-INDICE.md) - Visão geral completa
2. Todos os **RFCs** - Processo de decisão técnica
3. Todos os **ADRs** - Decisões permanentes
4. [Justificativa PostgreSQL](./04-JUSTIFICATIVA-POSTGRESQL.md) - Decisão de dados

**Tempo Estimado**: 2-3 horas (leitura completa)

---

### 📊 Para Gestores de Projeto
**Objetivo**: Entender custos, riscos e timeline

**Leitura Recomendada**:
1. [Diagrama de Componentes](./01-DIAGRAMA-COMPONENTES.md) - Seção "Custos Estimados"
2. [RFC-001 Cloud](./RFC-001-ESCOLHA-CLOUD.md) - Comparação de custos
3. [RFC-002 Database](./RFC-002-ESCOLHA-DATABASE.md) - Custo de banco de dados
4. [ADR-001 Serverless](./ADR-001-SERVERLESS-ARCHITECTURE.md) - Benefícios operacionais

**Tempo Estimado**: 45-60 minutos

---

### 🎓 Para Estudantes/Revisores FIAP
**Objetivo**: Avaliar completude e qualidade da documentação

**Leitura Recomendada**:
1. **TUDO** - Documentação completa para avaliação
2. Começar pelo [00-INDICE.md](./00-INDICE.md)
3. Revisar todos os diagramas
4. Verificar todos os RFCs e ADRs

**Tempo Estimado**: 3-4 horas (revisão completa)

---

## 📊 Diagramas Visuais

### 1. Arquitetura de Alto Nível
```
┌──────────────┐
│   Cliente    │
│ (Aplicação)  │
└──────┬───────┘
       │ HTTPS
       ▼
┌──────────────┐     ┌──────────────┐
│ API Gateway  │────>│    Lambda    │
│  (REST API)  │     │   (Java 21)  │
└──────────────┘     └──────┬───────┘
                            │ VPC
                            ▼
                     ┌──────────────┐
                     │      RDS     │
                     │  PostgreSQL  │
                     └──────────────┘
```

### 2. Fluxo de Dados
```
1. Cliente envia CPF
   ↓
2. API Gateway valida requisição
   ↓
3. Lambda valida CPF (algoritmo)
   ↓
4. Lambda consulta cliente no PostgreSQL
   ↓
5. Lambda gera token JWT
   ↓
6. Retorna token ao cliente
```

### 3. Pipeline CI/CD
```
Git Push
   ↓
GitHub Actions
   ↓
Build & Test
   ↓
Terraform Deploy
   ↓
Lambda Update
   ↓
Smoke Tests
   ↓
Deploy Completo ✅
```

---

## 🔍 Conceitos Chave

### Serverless
Arquitetura onde o provedor de cloud gerencia a infraestrutura, permitindo foco total no código de negócio.

**Benefícios**:
- ✅ Sem gerenciamento de servidores
- ✅ Escala automática
- ✅ Pay-per-use

**Trade-offs**:
- ❌ Cold starts
- ❌ Vendor lock-in

### Infrastructure as Code (IaC)
Gerenciamento de infraestrutura via código versionado (Terraform).

**Benefícios**:
- ✅ Reprodutível
- ✅ Versionado
- ✅ Revisável (code review)

### CI/CD
Continuous Integration / Continuous Deployment - automação de build, testes e deploy.

**Pipeline**:
- Build → Test → Deploy → Validate

---

## 📈 Métricas do Projeto

| Métrica | Valor |
|---------|-------|
| **Linhas de Código** | ~2.000 (Java + Terraform) |
| **Arquivos de Documentação** | 11 documentos |
| **Diagramas** | 3 principais |
| **RFCs** | 3 documentos |
| **ADRs** | 3 documentos |
| **Páginas de Documentação** | ~150 páginas |
| **Tempo de Elaboração** | ~40 horas |

---

## 🛠️ Ferramentas Utilizadas

### Desenvolvimento
- **IDE**: IntelliJ IDEA / VSCode
- **Build**: Maven
- **Runtime**: Java 21 (Amazon Corretto)
- **Testes**: JUnit 5, Mockito

### Infraestrutura
- **Cloud**: AWS (Lambda, RDS, API Gateway, VPC)
- **IaC**: Terraform 1.6+
- **Database**: PostgreSQL 16

### CI/CD
- **Pipeline**: GitHub Actions
- **Secrets**: GitHub Secrets, AWS Secrets Manager
- **Deploy**: Terraform + AWS CLI

### Monitoramento
- **Logs**: CloudWatch Logs
- **Métricas**: CloudWatch Metrics
- **APM**: New Relic (opcional)

---

## 📝 Convenções de Documentação

### Formato dos Documentos

**RFCs (Request for Comments)**:
- Propostas de decisões técnicas
- Análise de alternativas
- Matriz de decisão
- Status: PROPOSTO → APROVADO / REJEITADO

**ADRs (Architecture Decision Records)**:
- Decisões permanentes
- Contexto, decisão, consequências
- Status: PROPOSTO → ACEITO / SUBSTITUÍDO / OBSOLETO

**Justificativas**:
- Análises detalhadas de escolhas específicas
- Dados quantitativos
- Comparações técnicas

### Diagramas
- **ASCII Art**: Para visualização em terminal
- **Markdown Tables**: Para comparações
- **Mermaid** (futuro): Para diagramas interativos

---

## 🔄 Manutenção da Documentação

### Quando Atualizar

**Atualização Obrigatória**:
- ✅ Mudança de arquitetura significativa
- ✅ Nova tecnologia adotada
- ✅ Mudança de decisão técnica (novo ADR)

**Revisão Trimestral**:
- ✅ Validar métricas de custo
- ✅ Atualizar diagramas se necessário
- ✅ Revisar ADRs (ainda válidos?)

### Versionamento
```
Formato: X.Y
X = Major (mudança arquitetural significativa)
Y = Minor (correções, atualizações incrementais)

Atual: 2.0
```

---

## 🎓 Requisitos FIAP Atendidos

### ✅ Diagrama de Componentes
- [x] Visão de nuvem (AWS)
- [x] APIs (API Gateway)
- [x] Banco de dados (RDS PostgreSQL)
- [x] Monitoramento (CloudWatch)

**Documento**: [01-DIAGRAMA-COMPONENTES.md](./01-DIAGRAMA-COMPONENTES.md)

### ✅ Diagrama de Sequência
- [x] Fluxo de autenticação completo
- [x] Interações entre componentes
- [x] Tempos de processamento
- [x] Cenários de erro

**Documento**: [02-DIAGRAMA-SEQUENCIA-AUTH.md](./02-DIAGRAMA-SEQUENCIA-AUTH.md)

### ✅ RFCs (Request for Comments)
- [x] RFC-001: Escolha da nuvem (AWS)
- [x] RFC-002: Escolha do banco (PostgreSQL)
- [x] RFC-003: Estratégia de autenticação (JWT)

**Documentos**: RFC-001, RFC-002, RFC-003

### ✅ ADRs (Architecture Decision Records)
- [x] ADR-001: Arquitetura Serverless
- [x] ADR-004: Terraform (IaC)
- [x] ADR-006: CI/CD (GitHub Actions)

**Documentos**: ADR-001, ADR-004, ADR-006

### ✅ Justificativa de Banco de Dados
- [x] Comparação PostgreSQL vs DynamoDB vs Aurora
- [x] Diagrama ER
- [x] Explicação de relacionamentos
- [x] Normalização (3NF)
- [x] Constraints e índices
- [x] Análise de custos

**Documentos**: [03-DIAGRAMA-ER.md](./03-DIAGRAMA-ER.md), [04-JUSTIFICATIVA-POSTGRESQL.md](./04-JUSTIFICATIVA-POSTGRESQL.md)

---

## 🚀 Próximos Passos

### Para Novos Desenvolvedores
1. Ler [Diagrama de Componentes](./01-DIAGRAMA-COMPONENTES.md)
2. Configurar ambiente local (ver README.md principal)
3. Fazer primeiro deploy (seguir ADR-006)
4. Implementar feature e abrir PR

### Para Evolução da Documentação
1. Converter diagramas ASCII para Mermaid (interativos)
2. Adicionar diagramas de deployment
3. Criar ADR para decisões futuras (ex: migração para containers)
4. Documentar runbooks operacionais

---

## 📞 Contato

**Projeto**: Lambda Valida Pessoa - FIAP Fase 3  
**Equipe**: Equipe FIAP  
**Data**: 2025-12-04  
**Versão**: 2.0

Para dúvidas sobre esta documentação, consulte o índice completo em [00-INDICE.md](./00-INDICE.md).

---

**Última Atualização**: 2025-12-04  
**Próxima Revisão**: 2026-03-01

