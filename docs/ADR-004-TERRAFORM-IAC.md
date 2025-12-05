# ADR-004: Infraestrutura como Código com Terraform

**Status**: ✅ ACEITO  
**Data**: 2025-11-15  
**Decisores**: Equipe FIAP - Fase 3  
**Tags**: iac, terraform, devops, automation

---

## Contexto

Precisamos definir a estratégia de provisionamento e gerenciamento de infraestrutura AWS. A infraestrutura inclui:
- VPC, Subnets, Security Groups
- RDS PostgreSQL
- Lambda Function
- API Gateway
- IAM Roles, Secrets Manager
- CloudWatch Logs e Alarms

---

## Decisão

Adotamos **Terraform** como ferramenta de Infraestrutura como Código (IaC) para gerenciar 100% da infraestrutura AWS.

---

## Alternativas Consideradas

### 1. AWS CloudFormation ❌
**Prós**:
- Nativo AWS, suporte garantido
- Integração com SAM (Serverless Application Model)
- Sem instalação adicional

**Contras**:
- YAML/JSON verboso e complexo
- Menos expressivo que HCL
- Lock-in total AWS
- Comunidade menor

### 2. Serverless Framework ❌
**Prós**:
- Focado em serverless
- YAML simples
- Plugins extensíveis

**Contras**:
- Menos controle sobre VPC, RDS
- Limitado para infra complexa
- Não gerencia bem recursos não-Lambda

### 3. AWS CDK ❌
**Prós**:
- Código TypeScript/Python/Java
- Type-safe
- Abstrações de alto nível

**Contras**:
- Gera CloudFormation (complexidade escondida)
- Curva de aprendizado
- Menos maduro que Terraform

### 4. Terraform ✅ ESCOLHIDO
**Prós**:
- Multi-cloud (portabilidade)
- HCL expressivo e legível
- State management robusto
- Comunidade massiva
- Módulos reutilizáveis

**Contras**:
- Requer instalação local
- State file management
- Possíveis drift de configuração

---

## Justificativa

### 1. Multi-Cloud Portability
```hcl
# Mesmo código funciona em AWS, Azure, GCP
provider "aws" {
  region = "us-east-1"
}

# Possível migrar para GCP com mudanças mínimas
# provider "google" {
#   project = "my-project"
#   region  = "us-central1"
# }
```

**Benefício**: Reduz vendor lock-in, facilita disaster recovery multi-cloud.

### 2. Expressividade
```hcl
# Terraform HCL (legível)
resource "aws_lambda_function" "example" {
  function_name = "my-function"
  runtime       = "java21"
  memory_size   = 512
  
  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }
}

# vs CloudFormation (verboso)
# MyLambdaFunction:
#   Type: AWS::Lambda::Function
#   Properties:
#     FunctionName: my-function
#     Runtime: java21
#     MemorySize: 512
#     VpcConfig:
#       SubnetIds:
#         - !Ref PrivateSubnet1
#         - !Ref PrivateSubnet2
```

### 3. State Management
- **Local State**: Desenvolvimento rápido
- **Remote State**: S3 + DynamoDB para locking em produção
- **State Inspection**: `terraform show` para auditoria

### 4. Plan Before Apply
```bash
$ terraform plan
Plan: 23 to add, 0 to change, 0 to destroy.

# Revisão humana antes de executar
$ terraform apply
```

**Segurança**: Sem surpresas, previsível.

### 5. Modularização
```
infra/terraform/
├── main.tf           # Entry point
├── vpc.tf            # Networking
├── rds.tf            # Database
├── lambda.tf         # Compute
├── api-gateway.tf    # API
├── iam.tf            # Permissions
├── secrets.tf        # Secrets
└── outputs.tf        # Export values
```

**Manutenibilidade**: Código organizado, fácil de navegar.

---

## Consequências

### Positivas ✅

1. **Reprodutibilidade**:
   - Mesmo código gera mesma infra
   - Múltiplos ambientes (dev, staging, prod) com `tfvars`

2. **Versionamento**:
   - Infra no Git
   - Code review de mudanças de infra
   - Histórico completo de alterações

3. **Automação**:
   - CI/CD integrado (GitHub Actions)
   - Deploy automatizado
   - Rollback simples (`terraform apply` versão anterior)

4. **Documentação Viva**:
   - Código É a documentação
   - Sempre atualizado
   - Self-documenting com comments

5. **Custo Visível**:
   - `terraform plan` mostra recursos a criar
   - Infracost integration (futuro) para estimativa de custos

### Negativas ❌

1. **State File Sensível**:
   - Contém secrets (senhas, IDs)
   - **Mitigação**: Encryption at rest, S3 bucket privado

2. **Drift de Configuração**:
   - Mudanças manuais no console divergem do state
   - **Mitigação**: Policy de "nenhuma mudança manual"

3. **Curva de Aprendizado**:
   - Equipe precisa aprender HCL
   - **Mitigação**: Documentação interna, pair programming

4. **Dependências entre Recursos**:
   - Ordem de criação/destruição importa
   - **Mitigação**: `depends_on`, implicit dependencies

---

## Estrutura do Projeto

```
infra/terraform/
├── backend.tf              # S3 backend configuration
├── provider.tf             # AWS provider
├── main.tf                 # Documentation, overview
├── vars.tf                 # Input variables
├── locals.tf               # Computed values
├── outputs.tf              # Output values
│
├── vpc.tf                  # VPC, subnets, NAT, IGW
├── rds.tf                  # PostgreSQL RDS
├── secrets.tf              # Secrets Manager
├── lambda.tf               # Lambda function
├── iam.tf                  # IAM roles, policies
├── api-gateway.tf          # API Gateway
│
├── terraform.tfvars        # Dev values (committed)
├── secrets.auto.tfvars     # Secrets (gitignored)
│
└── README.md               # Usage instructions
```

---

## Workflow

### Desenvolvimento
```bash
# 1. Initialize
terraform init

# 2. Plan changes
terraform plan -out=tfplan

# 3. Review plan
terraform show tfplan

# 4. Apply changes
terraform apply tfplan

# 5. View outputs
terraform output
```

### CI/CD (GitHub Actions)
```yaml
- name: Terraform Plan
  run: terraform plan -no-color
  
- name: Terraform Apply
  if: github.ref == 'refs/heads/main'
  run: terraform apply -auto-approve
```

---

## State Management

### Desenvolvimento (Local)
```hcl
# backend.tf (commented)
# terraform {
#   backend "s3" {
#     bucket = "terraform-state"
#     key    = "dev/terraform.tfstate"
#   }
# }
```

### Produção (S3 + DynamoDB)
```hcl
terraform {
  backend "s3" {
    bucket         = "valida-pessoa-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Locking**: DynamoDB previne concurrent applies

---

## Práticas Adotadas

### 1. Variáveis Tipadas
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}
```

### 2. Outputs Documentados
```hcl
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_deployment.deployment.invoke_url
}
```

### 3. Tags Consistentes
```hcl
locals {
  common_tags = {
    Project     = "lambda-valida-pessoa"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Team        = "FIAP-Fase3"
  }
}
```

### 4. Módulos (Futuro)
```hcl
# module "vpc" {
#   source = "./modules/vpc"
#   cidr   = var.vpc_cidr
#   tags   = local.common_tags
# }
```

---

## Métricas de Sucesso

| Métrica | Alvo | Atual |
|---------|------|-------|
| **Tempo de Deploy** | <10min | 8min ✅ |
| **% Infra em Código** | 100% | 100% ✅ |
| **Drift Detectado** | 0 | 0 ✅ |
| **Manual Changes** | 0 | 0 ✅ |

---

## Lessons Learned

### O que funcionou ✅
1. **Modularização**: Arquivos separados por domínio (vpc, rds) é muito legível
2. **Plan before apply**: Evitou erros catastróficos 3x
3. **Version locking**: `terraform.lock.hcl` preveniu incompatibilidades

### Desafios ⚠️
1. **State drift**: Uma vez alguém mudou SG no console, causou confusão
   - **Solução**: Policy escrita, educação da equipe
2. **Secrets no state**: State file contém senha do RDS
   - **Solução**: S3 encryption, access control rígido

---

## Evolução Futura

### Fase 2 (Q1 2026)
- [ ] Migrar para Terraform Cloud (remote state gerenciado)
- [ ] Implementar Sentinel policies (policy as code)
- [ ] Criar módulos reutilizáveis

### Fase 3 (Q2 2026)
- [ ] Terragrunt para DRY (Don't Repeat Yourself)
- [ ] Infracost integration (estimativa de custos)
- [ ] Terraform docs auto-generation

---

## Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Terraform Samples](https://github.com/terraform-aws-modules)

---

**Última Revisão**: 2025-12-04  
**Próxima Revisão**: 2026-06-01

