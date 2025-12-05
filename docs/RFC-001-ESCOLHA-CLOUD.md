# RFC-001: Escolha da Plataforma de Nuvem

**Status**: ✅ APROVADO  
**Data**: 2025-11-15  
**Autor**: Equipe FIAP - Fase 3  
**Decisão**: AWS (Amazon Web Services)

---

## 📋 Sumário Executivo

Este RFC documenta a análise e decisão sobre a escolha da plataforma de nuvem para o sistema Lambda Valida Pessoa. Após avaliação de três principais provedores (AWS, Azure e GCP), decidiu-se pela **AWS** como plataforma principal.

---

## 🎯 Contexto e Problema

### Requisitos do Projeto

O sistema Lambda Valida Pessoa requer:

1. **Arquitetura Serverless**: Função sob demanda sem gerenciamento de servidores
2. **API Gateway**: Endpoint HTTP/HTTPS gerenciado
3. **Banco de Dados Relacional**: PostgreSQL gerenciado
4. **Rede Privada**: VPC para isolamento de recursos
5. **Gerenciamento de Secrets**: Armazenamento seguro de credenciais
6. **Observabilidade**: Logs, métricas e alertas
7. **IaC Support**: Terraform como ferramenta principal

### Restrições

- **Orçamento**: Limitado (~$100/mês em desenvolvimento)
- **Expertise**: Equipe com conhecimento variado em cloud
- **Timeline**: 4 semanas para MVP
- **Escalabilidade**: Suportar até 10.000 req/dia inicialmente

---

## 🔍 Análise Comparativa

### Opção 1: AWS (Amazon Web Services)

#### Serviços Utilizados
- **Compute**: Lambda
- **API**: API Gateway
- **Database**: RDS PostgreSQL
- **Network**: VPC, Security Groups
- **Security**: Secrets Manager, IAM
- **Monitoring**: CloudWatch
- **IaC**: Terraform (AWS Provider)

#### Vantagens ✅

1. **Maturidade Serverless**:
   - Lambda é o serviço serverless mais maduro do mercado (lançado em 2014)
   - Maior ecossistema de integrações
   - Documentação extensa e comunidade ativa

2. **Terraform Support**:
   - AWS Provider é o mais completo e estável
   - Comunidade Terraform focada principalmente em AWS
   - Módulos prontos disponíveis

3. **Free Tier Generoso**:
   - Lambda: 1M requests/mês grátis
   - API Gateway: 1M calls/mês (12 meses)
   - RDS: db.t3.micro 750h/mês (12 meses)
   - CloudWatch: 5GB logs/mês grátis

4. **Integração Nativa**:
   - Lambda ↔ RDS via VPC (sem intermediários)
   - API Gateway ↔ Lambda (integração direta)
   - Secrets Manager ↔ Lambda (SDK nativo)
   - CloudWatch integrado em todos os serviços

5. **Custo Previsível**:
   - Calculadora de custos detalhada
   - Pay-per-use sem compromisso mínimo
   - Alertas de billing configuráveis

#### Desvantagens ❌

1. **Complexidade de VPC**:
   - Configuração de VPC, subnets, NAT Gateway é complexa
   - NAT Gateway tem custo fixo (~$32/mês)
   - Cold start maior para Lambda em VPC (~1-2s)

2. **Lock-in**:
   - APIs proprietárias (CloudWatch, Secrets Manager)
   - Migração para outra cloud requer refatoração significativa

3. **Custo de Rede**:
   - NAT Gateway obrigatório para Lambda em VPC acessar internet
   - Transferência de dados entre AZs tem custo

#### Custo Estimado (Mensal)

| Serviço | Configuração | Custo |
|---------|--------------|-------|
| Lambda | 1M requests, 512MB, 200ms avg | $5 |
| API Gateway | 1M requests | $3.50 |
| RDS | db.t3.micro, 20GB | $25 |
| NAT Gateway | 1 gateway, 10GB transfer | $35 |
| Secrets Manager | 1 secret | $0.40 |
| CloudWatch | 5GB logs | $2.50 |
| **TOTAL** | - | **$71.40** |

**Com Free Tier (primeiros 12 meses)**: ~$40/mês

---

### Opção 2: Azure

#### Serviços Equivalentes
- **Compute**: Azure Functions
- **API**: API Management / Azure Functions Proxies
- **Database**: Azure Database for PostgreSQL
- **Network**: Virtual Network
- **Security**: Key Vault, Azure AD
- **Monitoring**: Application Insights
- **IaC**: Terraform (AzureRM Provider)

#### Vantagens ✅

1. **Integração Microsoft**:
   - Boa integração com ferramentas Microsoft (AD, Office 365)
   - Azure DevOps nativo

2. **Hybrid Cloud**:
   - Forte suporte a cenários híbridos (Azure Arc)
   - Boa opção se houver infraestrutura on-premise

3. **Preços Competitivos**:
   - Azure Functions consumption plan sem custo de "idle time"
   - Descontos para estudantes/educação (Azure for Students)

#### Desvantagens ❌

1. **Menor Maturidade Serverless**:
   - Azure Functions lançado em 2016 (2 anos depois do Lambda)
   - Menos integrações nativas
   - Documentação menos abrangente

2. **API Management Complexo**:
   - API Management é mais robusto, mas também mais complexo
   - Custo adicional se usar tier completo (~$50/mês)

3. **Terraform Support**:
   - AzureRM provider menos maduro que AWS
   - Algumas features requerem ARM templates
   - Comunidade menor

4. **Cold Start**:
   - Azure Functions tem cold starts similares ou piores que Lambda
   - Consumption plan não garante warm instances

#### Custo Estimado (Mensal)

| Serviço | Configuração | Custo |
|---------|--------------|-------|
| Azure Functions | 1M requests, 512MB | $4 |
| API Management (Consumption) | 1M calls | $4 |
| PostgreSQL | Basic tier, 20GB | $30 |
| Virtual Network | NAT Gateway | $35 |
| Key Vault | 1 secret | $0.30 |
| Application Insights | 5GB | $2.30 |
| **TOTAL** | - | **$75.60** |

---

### Opção 3: GCP (Google Cloud Platform)

#### Serviços Equivalentes
- **Compute**: Cloud Functions
- **API**: Cloud Endpoints / API Gateway (beta)
- **Database**: Cloud SQL PostgreSQL
- **Network**: VPC
- **Security**: Secret Manager, IAM
- **Monitoring**: Cloud Logging, Cloud Monitoring
- **IaC**: Terraform (Google Provider)

#### Vantagens ✅

1. **Performance de Rede**:
   - Rede global do Google é excepcional
   - VPC global (sem conceito de região)
   - Menor latência entre regiões

2. **BigQuery Integration**:
   - Se precisar analytics, BigQuery é imbatível
   - Integração nativa com Cloud Functions

3. **Pricing Simples**:
   - Modelo de pricing mais transparente
   - Menos "surpresas" com custos de rede

4. **Kubernetes Native**:
   - GKE é o melhor Kubernetes gerenciado
   - Boa opção se planejar migrar para containers

#### Desvantagens ❌

1. **Menor Adoção**:
   - Quota de mercado menor (~10% vs 32% AWS)
   - Comunidade menor, menos exemplos

2. **API Gateway Imaturo**:
   - GCP API Gateway ainda em beta
   - Cloud Endpoints é complexo para casos simples

3. **Terraform Support**:
   - Google Provider é bom, mas comunidade menor que AWS
   - Alguns recursos não disponíveis

4. **Cloud Functions Limitações**:
   - Menos runtimes suportados
   - Documentação menos extensa

5. **Free Tier Menor**:
   - Cloud Functions: apenas 2M invocations/mês (vs 1M Lambda mas com mais recursos)
   - Cloud SQL não tem free tier

#### Custo Estimado (Mensal)

| Serviço | Configuração | Custo |
|---------|--------------|-------|
| Cloud Functions | 1M requests, 512MB | $5 |
| Cloud Endpoints | 1M calls | $0 (grátis até 2M) |
| Cloud SQL | db-f1-micro, 20GB | $25 |
| VPC | Cloud NAT | $30 |
| Secret Manager | 1 secret | $0.30 |
| Cloud Logging | 5GB | $2.50 |
| **TOTAL** | - | **$62.80** |

---

## 📊 Matriz de Decisão

| Critério | Peso | AWS | Azure | GCP |
|----------|------|-----|-------|-----|
| **Maturidade Serverless** | 25% | 10 | 7 | 7 |
| **Terraform Support** | 20% | 10 | 7 | 8 |
| **Documentação** | 15% | 10 | 7 | 7 |
| **Custo (dev)** | 15% | 7 | 6 | 9 |
| **Free Tier** | 10% | 10 | 8 | 6 |
| **Comunidade** | 10% | 10 | 7 | 6 |
| **Facilidade de Uso** | 5% | 7 | 7 | 8 |
| **TOTAL** | 100% | **9.15** | **7.00** | **7.35** |

**Pontuação**: 1-10 (1 = pior, 10 = melhor)

---

## ✅ Decisão

### Escolha: **AWS (Amazon Web Services)**

### Justificativa

1. **Maturidade e Confiabilidade**: Lambda é o serviço serverless mais maduro e confiável do mercado

2. **Ecossistema Terraform**: AWS Provider é o mais completo e estável, crucial para IaC

3. **Documentação e Comunidade**: Facilita desenvolvimento e troubleshooting

4. **Free Tier**: Reduz custos nos primeiros 12 meses, ideal para MVP

5. **Experiência da Equipe**: Membros com experiência prévia em AWS

6. **Integração Nativa**: Todos os serviços se integram nativamente sem intermediários

---

## 🎯 Próximos Passos

### Curto Prazo (Sprint 1-2)
- [x] Criar conta AWS
- [x] Configurar IAM users e roles
- [x] Setup Terraform backend (S3 + DynamoDB)
- [x] Provisionar infraestrutura base (VPC, RDS)

### Médio Prazo (Sprint 3-4)
- [x] Deploy Lambda e API Gateway
- [x] Configurar monitoramento CloudWatch
- [x] Setup alertas e dashboards
- [x] Documentar runbooks

### Longo Prazo (Pós-MVP)
- [ ] Avaliar Reserved Instances para RDS (economia de 40-60%)
- [ ] Implementar VPC Endpoints (reduzir custo de NAT)
- [ ] Considerar Aurora Serverless v2 para RDS
- [ ] Avaliar Lambda SnapStart para cold starts

---

## 🔄 Critérios de Revisão

Esta decisão deve ser revisada se:

1. **Custo Mensal > $150**: Avaliar otimizações ou alternativas
2. **Cold Starts > 3s**: Considerar outras plataformas ou arquiteturas
3. **Downtime > 0.5%**: Reavaliar SLA e alternativas
4. **Mudança de Requisitos**: Ex: necessidade de híbrido (favorece Azure)
5. **Mudança de Equipe**: Se expertise mudar para outra cloud

**Próxima Revisão**: 2026-01-01 (após 12 meses)

---

## 📚 Referências

- [AWS Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
- [AWS vs Azure vs GCP Comparison (2024)](https://www.cloudzero.com/blog/aws-vs-azure-vs-google-cloud)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

## 📝 Histórico de Alterações

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 2025-11-15 | Equipe FIAP | Versão inicial |
| 1.1 | 2025-11-20 | Equipe FIAP | Adicionada análise de custos detalhada |
| 2.0 | 2025-12-04 | Equipe FIAP | Aprovação final e implementação completa |

---

**Status Final**: ✅ IMPLEMENTADO  
**Aprovado por**: Equipe FIAP - Fase 3  
**Data de Aprovação**: 2025-11-20

