# 📚 Documentação da Arquitetura - Sistema Lambda Valida Pessoa

## Índice da Documentação

Esta documentação fornece uma visão completa da arquitetura do sistema de autenticação serverless baseado em AWS Lambda, incluindo diagramas, decisões arquiteturais e justificativas técnicas.

---

## 📂 Estrutura da Documentação

### 1. Diagramas Arquiteturais
- **[Diagrama de Componentes](./01-DIAGRAMA-COMPONENTES.md)** - Visão de nuvem, APIs, banco de dados e monitoramento
- **[Diagrama de Sequência - Autenticação](./02-DIAGRAMA-SEQUENCIA-AUTH.md)** - Fluxo completo de autenticação JWT
- **[Diagrama ER - Banco de Dados](./03-DIAGRAMA-ER.md)** - Modelo de dados relacional

### 2. RFCs (Request for Comments)
Documentos de propostas técnicas para decisões importantes:

- **[RFC-001: Escolha da Plataforma de Nuvem](./RFC-001-ESCOLHA-CLOUD.md)** - AWS vs Azure vs GCP
- **[RFC-002: Escolha do Banco de Dados](./RFC-002-ESCOLHA-DATABASE.md)** - PostgreSQL RDS vs DynamoDB vs Aurora
- **[RFC-003: Estratégia de Autenticação](./RFC-003-ESTRATEGIA-AUTENTICACAO.md)** - JWT vs OAuth2 vs Cognito

### 3. ADRs (Architecture Decision Records)
Registros permanentes de decisões arquiteturais:

- **[ADR-001: Arquitetura Serverless com AWS Lambda](./ADR-001-SERVERLESS-ARCHITECTURE.md)**
- **[ADR-002: Padrão de Comunicação Síncrona via API Gateway](./ADR-002-API-GATEWAY-SYNC.md)**
- **[ADR-003: Uso de VPC para Isolamento de Rede](./ADR-003-VPC-NETWORKING.md)**
- **[ADR-004: Infraestrutura como Código com Terraform](./ADR-004-TERRAFORM-IAC.md)**
- **[ADR-005: Monitoramento com CloudWatch e New Relic](./ADR-005-MONITORING-STRATEGY.md)**
- **[ADR-006: CI/CD com GitHub Actions](./ADR-006-CICD-GITHUB-ACTIONS.md)**

### 4. Justificativas Técnicas
- **[Justificativa: Escolha do PostgreSQL RDS](./04-JUSTIFICATIVA-POSTGRESQL.md)** - Análise detalhada e comparação
- **[Modelo Relacional e Normalização](./05-MODELO-RELACIONAL.md)** - Design do banco de dados

### 5. Documentação Complementar
- **[Guia de Deploy](./06-GUIA-DEPLOY.md)** - Procedimentos de implantação
- **[Guia de Monitoramento](./07-GUIA-MONITORAMENTO.md)** - Métricas e alertas
- **[Plano de Disaster Recovery](./08-DISASTER-RECOVERY.md)** - Estratégias de recuperação
- **[Análise de Custos AWS](./09-ANALISE-CUSTOS.md)** - Estimativa de custos mensais

---

## 🎯 Visão Geral do Sistema

### Descrição
Sistema serverless de autenticação baseado em CPF/CNPJ que implementa:
- Validação rigorosa de documentos brasileiros (CPF/CNPJ)
- Consulta de clientes em banco PostgreSQL
- Geração de tokens JWT para autenticação
- API REST totalmente gerenciada

### Principais Características
- **Serverless**: Zero gerenciamento de servidores
- **Escalável**: Escala automaticamente com a demanda
- **Seguro**: VPC isolada, credenciais no Secrets Manager
- **Observável**: Logs estruturados e métricas customizadas
- **Automatizado**: CI/CD completo com GitHub Actions

### Tecnologias Principais
- **Runtime**: Java 21
- **Cloud**: AWS (Lambda, API Gateway, RDS, VPC)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions
- **Monitoramento**: CloudWatch + New Relic (opcional)
- **Banco de Dados**: PostgreSQL 16

---

## 📊 Métricas do Projeto

| Métrica | Valor |
|---------|-------|
| **Linhas de Código** | ~2.000 (Java + Terraform) |
| **Cobertura de Testes** | >80% |
| **Recursos AWS** | 25+ recursos gerenciados |
| **Tempo de Deploy** | ~8-10 minutos |
| **Cold Start** | ~1-2 segundos |
| **Warm Response** | ~100-200ms |
| **Custo Mensal Estimado** | ~$50-80 USD |

---

## 🚀 Como Usar Esta Documentação

### Para Desenvolvedores
1. Comece com os **Diagramas** para entender a arquitetura
2. Leia os **ADRs** para compreender decisões tomadas
3. Consulte o **Guia de Deploy** para implementação

### Para Arquitetos
1. Revise os **RFCs** para entender o processo de decisão
2. Analise os **ADRs** para contexto das escolhas
3. Examine a **Justificativa do PostgreSQL** para decisões de dados

### Para Gestores
1. Consulte a **Análise de Custos** para orçamento
2. Revise o **Plano de Disaster Recovery** para riscos
3. Examine as **Métricas** para KPIs

---

## 📝 Convenções de Documentação

### Símbolos Usados
- ✅ **Implementado**: Recurso completamente funcional
- 🚧 **Em Desenvolvimento**: Recurso em construção
- ⏸️ **Opcional**: Recurso desativado mas disponível
- ❌ **Não Implementado**: Recurso planejado mas não desenvolvido

### Níveis de Prioridade
- 🔴 **Alta**: Crítico para funcionamento
- 🟡 **Média**: Importante mas não bloqueante
- 🟢 **Baixa**: Nice to have

---

## 📅 Histórico de Revisões

| Versão | Data | Autor | Descrição |
|--------|------|-------|-----------|
| 1.0.0 | 2025-12-04 | Equipe FIAP | Documentação inicial completa |

---

## 📞 Contato e Suporte

Para dúvidas sobre esta documentação:
- **Projeto**: Lambda Valida Pessoa - FIAP Fase 3
- **Repositório**: [GitHub](https://github.com/seu-repo)
- **Documentação Online**: [Wiki do Projeto]

---

## 📖 Referências

- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [JWT RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)


