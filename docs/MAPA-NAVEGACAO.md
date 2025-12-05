# 🗺️ Mapa de Navegação - Documentação Arquitetural

## Guia Visual Completo da Documentação

**Última Atualização**: 2025-12-04  
**Total de Documentos**: 14 arquivos

---

## 📁 Estrutura de Arquivos

```
docs/
│
├── 📑 00-INDICE.md                          ⭐ COMECE AQUI
├── 📖 README.md                             Guia de uso da documentação
├── 📊 RESUMO-EXECUTIVO.md                   Visão geral completa
│
├── 🏗️ DIAGRAMAS ARQUITETURAIS
│   ├── 01-DIAGRAMA-COMPONENTES.md          Arquitetura AWS completa
│   ├── 02-DIAGRAMA-SEQUENCIA-AUTH.md       Fluxo de autenticação
│   └── 03-DIAGRAMA-ER.md                    Modelo de dados
│
├── 📄 RFCs (Request for Comments)
│   ├── RFC-001-ESCOLHA-CLOUD.md            AWS vs Azure vs GCP
│   ├── RFC-002-ESCOLHA-DATABASE.md         PostgreSQL vs DynamoDB
│   └── RFC-003-ESTRATEGIA-AUTENTICACAO.md  JWT vs Cognito
│
├── ✅ ADRs (Architecture Decision Records)
│   ├── ADR-001-SERVERLESS-ARCHITECTURE.md  Por quê Serverless?
│   ├── ADR-002-API-GATEWAY-SYNC.md         Por quê REST síncrono?
│   ├── ADR-004-TERRAFORM-IAC.md            Por quê Terraform?
│   └── ADR-006-CICD-GITHUB-ACTIONS.md      Por quê GitHub Actions?
│
└── 📊 JUSTIFICATIVAS
    └── 04-JUSTIFICATIVA-POSTGRESQL.md       Análise detalhada PostgreSQL
```

---

## 🎯 Roteiros de Leitura

### 🚀 Roteiro Rápido (30 minutos)
**Objetivo**: Entender a arquitetura básica

1. **[RESUMO-EXECUTIVO.md](./RESUMO-EXECUTIVO.md)** (10 min)
   - Visão geral do projeto
   - Stack tecnológica
   - Métricas e resultados

2. **[01-DIAGRAMA-COMPONENTES.md](./01-DIAGRAMA-COMPONENTES.md)** (15 min)
   - Seções: Diagrama principal, Componentes, Fluxo de dados
   - Pular seções detalhadas na primeira leitura

3. **[02-DIAGRAMA-SEQUENCIA-AUTH.md](./02-DIAGRAMA-SEQUENCIA-AUTH.md)** (5 min)
   - Apenas o diagrama de sucesso
   - Tabela de tempos

---

### 📚 Roteiro Completo (3 horas)
**Objetivo**: Compreensão total da arquitetura

#### Fase 1: Contextualização (30 min)
1. [00-INDICE.md](./00-INDICE.md) - 5 min
2. [RESUMO-EXECUTIVO.md](./RESUMO-EXECUTIVO.md) - 15 min
3. [README.md](./README.md) - 10 min

#### Fase 2: Arquitetura (45 min)
4. [01-DIAGRAMA-COMPONENTES.md](./01-DIAGRAMA-COMPONENTES.md) - 25 min
5. [02-DIAGRAMA-SEQUENCIA-AUTH.md](./02-DIAGRAMA-SEQUENCIA-AUTH.md) - 20 min

#### Fase 3: Decisões Técnicas (60 min)
6. [RFC-001-ESCOLHA-CLOUD.md](./RFC-001-ESCOLHA-CLOUD.md) - 20 min
7. [RFC-002-ESCOLHA-DATABASE.md](./RFC-002-ESCOLHA-DATABASE.md) - 20 min
8. [RFC-003-ESTRATEGIA-AUTENTICACAO.md](./RFC-003-ESTRATEGIA-AUTENTICACAO.md) - 20 min

#### Fase 4: Decisões Permanentes (45 min)
9. [ADR-001-SERVERLESS-ARCHITECTURE.md](./ADR-001-SERVERLESS-ARCHITECTURE.md) - 15 min
10. [ADR-002-API-GATEWAY-SYNC.md](./ADR-002-API-GATEWAY-SYNC.md) - 10 min
11. [ADR-004-TERRAFORM-IAC.md](./ADR-004-TERRAFORM-IAC.md) - 10 min
12. [ADR-006-CICD-GITHUB-ACTIONS.md](./ADR-006-CICD-GITHUB-ACTIONS.md) - 10 min

#### Fase 5: Detalhamento de Dados (30 min)
13. [03-DIAGRAMA-ER.md](./03-DIAGRAMA-ER.md) - 15 min
14. [04-JUSTIFICATIVA-POSTGRESQL.md](./04-JUSTIFICATIVA-POSTGRESQL.md) - 15 min

---

### 🎓 Roteiro para Avaliadores FIAP (2 horas)
**Objetivo**: Verificar atendimento aos requisitos

#### Checklist de Avaliação

**1. Diagrama de Componentes** ✅
- [ ] Abrir: `01-DIAGRAMA-COMPONENTES.md`
- [ ] Verificar: Visão de nuvem (AWS)
- [ ] Verificar: APIs (API Gateway)
- [ ] Verificar: Banco de dados (RDS)
- [ ] Verificar: Monitoramento (CloudWatch)
- **Tempo**: 15 minutos

**2. Diagrama de Sequência** ✅
- [ ] Abrir: `02-DIAGRAMA-SEQUENCIA-AUTH.md`
- [ ] Verificar: Fluxo de autenticação
- [ ] Verificar: Interações entre componentes
- [ ] Verificar: Cenários de erro
- **Tempo**: 15 minutos

**3. RFCs** ✅
- [ ] Abrir: `RFC-001-ESCOLHA-CLOUD.md`
- [ ] Verificar: Análise de 3+ alternativas
- [ ] Verificar: Matriz de decisão
- [ ] Repetir para RFC-002 e RFC-003
- **Tempo**: 30 minutos

**4. ADRs** ✅
- [ ] Abrir: `ADR-001-SERVERLESS-ARCHITECTURE.md`
- [ ] Verificar: Contexto, decisão, consequências
- [ ] Verificar: Decisões permanentes documentadas
- [ ] Repetir para ADR-002, ADR-004, ADR-006
- **Tempo**: 25 minutos

**5. Justificativa de Banco** ✅
- [ ] Abrir: `04-JUSTIFICATIVA-POSTGRESQL.md`
- [ ] Verificar: Comparação detalhada
- [ ] Verificar: Diagrama ER em `03-DIAGRAMA-ER.md`
- [ ] Verificar: Explicação de relacionamentos
- [ ] Verificar: Normalização documentada
- **Tempo**: 25 minutos

**6. Qualidade Geral** ✅
- [ ] Verificar consistência de formatação
- [ ] Verificar profundidade técnica
- [ ] Verificar exemplos de código
- [ ] Verificar diagramas visuais
- **Tempo**: 10 minutos

---

## 📊 Matriz de Conteúdo

| Documento | Páginas | Diagramas | Tabelas | Código | Nível Técnico |
|-----------|---------|-----------|---------|--------|---------------|
| **00-INDICE** | 3 | 0 | 3 | 0 | ⭐ Básico |
| **README** | 8 | 3 | 4 | 2 | ⭐⭐ Intermediário |
| **RESUMO-EXEC** | 12 | 1 | 8 | 0 | ⭐⭐ Intermediário |
| **01-COMPONENTES** | 35 | 5 | 12 | 5 | ⭐⭐⭐ Avançado |
| **02-SEQUENCIA** | 42 | 5 | 6 | 15 | ⭐⭐⭐ Avançado |
| **03-ER** | 25 | 3 | 8 | 20 | ⭐⭐⭐ Avançado |
| **RFC-001** | 15 | 1 | 5 | 0 | ⭐⭐ Intermediário |
| **RFC-002** | 18 | 1 | 6 | 8 | ⭐⭐⭐ Avançado |
| **RFC-003** | 12 | 0 | 4 | 5 | ⭐⭐ Intermediário |
| **ADR-001** | 8 | 1 | 3 | 2 | ⭐⭐ Intermediário |
| **ADR-002** | 12 | 1 | 4 | 8 | ⭐⭐ Intermediário |
| **ADR-004** | 10 | 0 | 3 | 12 | ⭐⭐⭐ Avançado |
| **ADR-006** | 15 | 3 | 5 | 10 | ⭐⭐⭐ Avançado |
| **04-JUSTIF-PG** | 40 | 4 | 15 | 25 | ⭐⭐⭐ Avançado |
| **TOTAL** | **~255** | **28** | **86** | **112** | - |

---

## 🔍 Busca por Tópico

### Arquitetura AWS
- **Principal**: [01-DIAGRAMA-COMPONENTES.md](./01-DIAGRAMA-COMPONENTES.md)
- **Decisão**: [RFC-001-ESCOLHA-CLOUD.md](./RFC-001-ESCOLHA-CLOUD.md)
- **Serverless**: [ADR-001-SERVERLESS-ARCHITECTURE.md](./ADR-001-SERVERLESS-ARCHITECTURE.md)

### Banco de Dados
- **Principal**: [03-DIAGRAMA-ER.md](./03-DIAGRAMA-ER.md)
- **Decisão**: [RFC-002-ESCOLHA-DATABASE.md](./RFC-002-ESCOLHA-DATABASE.md)
- **Justificativa**: [04-JUSTIFICATIVA-POSTGRESQL.md](./04-JUSTIFICATIVA-POSTGRESQL.md)

### Autenticação
- **Fluxo**: [02-DIAGRAMA-SEQUENCIA-AUTH.md](./02-DIAGRAMA-SEQUENCIA-AUTH.md)
- **Decisão**: [RFC-003-ESTRATEGIA-AUTENTICACAO.md](./RFC-003-ESTRATEGIA-AUTENTICACAO.md)
- **API**: [ADR-002-API-GATEWAY-SYNC.md](./ADR-002-API-GATEWAY-SYNC.md)

### Infraestrutura como Código
- **Principal**: [ADR-004-TERRAFORM-IAC.md](./ADR-004-TERRAFORM-IAC.md)
- **Arquitetura**: [01-DIAGRAMA-COMPONENTES.md](./01-DIAGRAMA-COMPONENTES.md) (seção Terraform)

### CI/CD
- **Principal**: [ADR-006-CICD-GITHUB-ACTIONS.md](./ADR-006-CICD-GITHUB-ACTIONS.md)
- **Workflows**: Ver `.github/workflows/` no repositório

### Custos
- **Resumo**: [RESUMO-EXECUTIVO.md](./RESUMO-EXECUTIVO.md) (seção Custos)
- **AWS**: [RFC-001-ESCOLHA-CLOUD.md](./RFC-001-ESCOLHA-CLOUD.md) (análise comparativa)
- **Database**: [RFC-002-ESCOLHA-DATABASE.md](./RFC-002-ESCOLHA-DATABASE.md) (comparação)

### Performance
- **Métricas**: [RESUMO-EXECUTIVO.md](./RESUMO-EXECUTIVO.md) (seção Performance)
- **Sequência**: [02-DIAGRAMA-SEQUENCIA-AUTH.md](./02-DIAGRAMA-SEQUENCIA-AUTH.md) (tempos)
- **Índices**: [03-DIAGRAMA-ER.md](./03-DIAGRAMA-ER.md) (performance de queries)

---

## 💡 Dicas de Navegação

### Para Leitura Offline
```bash
# Clonar repositório
git clone <repo-url>

# Navegar para docs
cd lambda-valida-pessoa/docs

# Abrir no editor favorito
code .  # VS Code
# ou
vim 00-INDICE.md  # Vim
```

### Para Busca Rápida
```bash
# Buscar termo em todos os documentos
grep -r "serverless" docs/

# Buscar termo específico
grep -r "PostgreSQL" docs/ | grep -i "custo"
```

### Para Impressão (PDF)
**Recomendação**: Usar Markdown to PDF converter

```bash
# Usando pandoc
pandoc 01-DIAGRAMA-COMPONENTES.md -o componentes.pdf

# Ou VS Code extension: Markdown PDF
```

---

## 📚 Glossário de Termos

| Termo | Significado | Documento Ref |
|-------|-------------|---------------|
| **ADR** | Architecture Decision Record | ADR-* |
| **RFC** | Request for Comments | RFC-* |
| **IaC** | Infrastructure as Code | ADR-004 |
| **JWT** | JSON Web Token | RFC-003, ADR-002 |
| **RDS** | Relational Database Service | RFC-002, 03-ER |
| **VPC** | Virtual Private Cloud | 01-COMPONENTES |
| **SLA** | Service Level Agreement | RESUMO-EXEC |
| **ACU** | Aurora Capacity Unit | RFC-002 |
| **CORS** | Cross-Origin Resource Sharing | ADR-002 |
| **NAT** | Network Address Translation | 01-COMPONENTES |

---

## 🎯 Objetivos de Aprendizado

Após ler esta documentação, você será capaz de:

✅ **Compreender** a arquitetura serverless completa  
✅ **Explicar** decisões técnicas tomadas (RFCs e ADRs)  
✅ **Justificar** escolha de tecnologias  
✅ **Implementar** melhorias ou extensões  
✅ **Debugar** problemas usando diagramas de sequência  
✅ **Estimar** custos de infraestrutura  
✅ **Replicar** o projeto em outro ambiente  

---

## 📞 Suporte

### Dúvidas sobre Documentação
- Consultar [00-INDICE.md](./00-INDICE.md)
- Ver [README.md](./README.md)

### Dúvidas Técnicas
- Revisar ADR relevante
- Consultar seção "Consequências"

### Sugestões de Melhoria
- Abrir issue no GitHub
- Propor pull request com melhorias

---

**Última Atualização**: 2025-12-04  
**Versão**: 2.0  
**Mantenedor**: Equipe FIAP - Fase 3

---

## ✅ Status da Documentação

| Categoria | Status | Completude |
|-----------|--------|------------|
| **Diagramas** | ✅ Completo | 100% |
| **RFCs** | ✅ Completo | 100% |
| **ADRs** | ✅ Completo | 100% |
| **Justificativas** | ✅ Completo | 100% |
| **Navegação** | ✅ Completo | 100% |
| **Exemplos de Código** | ✅ Completo | 100% |
| **TOTAL** | ✅ **COMPLETO** | **100%** |

---

🎉 **Documentação Completa e Pronta para Entrega!**

