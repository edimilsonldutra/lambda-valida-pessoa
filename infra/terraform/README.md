# Terraform AWS Infrastructure - Valida Pessoa

## Arquitetura

Esta infraestrutura segue as melhores práticas da AWS:

### Rede
- **VPC**: 10.0.0.0/16
- **Subnets Públicas**: 2 subnets em AZs diferentes (10.0.1.0/24, 10.0.2.0/24)
- **Subnets Privadas**: 2 subnets em AZs diferentes (10.0.11.0/24, 10.0.12.0/24)
- **NAT Gateway**: Em subnet pública para acesso à internet de recursos privados
- **Internet Gateway**: Para acesso à internet de subnets públicas
- **VPC Endpoints**: Secrets Manager (opcional, reduz custos de NAT)

### RDS PostgreSQL
- **Localização**: Subnets privadas
- **Versão**: PostgreSQL 16.3
- **Classe**: db.t4g.micro (ajustável)
- **Storage**: 20GB GP3 com criptografia
- **Multi-AZ**: Configurável (recomendado para produção)
- **Backup**: Janela de 03:00-04:00, retenção configurável
- **Logs**: CloudWatch Logs habilitados

### Lambda
- **Runtime**: Java 21
- **Localização**: Subnets privadas
- **VPC Config**: ENIs criadas automaticamente
- **Acesso RDS**: Via Security Group
- **Acesso Secrets**: Via VPC Endpoint ou NAT Gateway

### Security Groups
- **Lambda SG**: Apenas egress permitido
- **RDS SG**: Ingress apenas da Lambda na porta 5432
- **VPC Endpoints SG**: HTTPS (443) da VPC

### Secrets Manager
- Credenciais do RDS armazenadas com segurança
- Lambda acessa via IAM policy
- JSON com: username, password, host, port, dbname, engine

## Pré-requisitos

1. **AWS CLI** configurado
2. **Terraform** >= 1.0
3. **JAR da Lambda** compilado em: `../../LambdaValidaPessoa/target/ValidaPessoa-1.0.jar`

## Deploy

### 1. Compilar a Lambda

```bash
cd ../../LambdaValidaPessoa
mvn clean package -DskipTests
```

### 2. Configurar variáveis

Copie e edite o arquivo de exemplo:

```bash
cp terraform.tfvars.example terraform.tfvars
```

**Variáveis obrigatórias:**
- `db_password`: Senha forte para o RDS
- `jwt_secret`: Mínimo 32 caracteres

### 3. Inicializar Terraform

```bash
terraform init
```

### 4. Planejar infraestrutura

```bash
terraform plan
```

### 5. Aplicar infraestrutura

```bash
terraform apply
```

**Tempo estimado**: 10-15 minutos (RDS leva mais tempo)

### 6. Executar migração do banco

Após o RDS estar disponível, execute o script SQL:

```bash
# Obter endpoint do RDS
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Executar migration
psql -h $RDS_ENDPOINT -U postgres -d valida_pessoa -f ../../scripts/migrations.sql
```

## Outputs

Após o apply, você terá acesso aos seguintes outputs:

```bash
terraform output
```

- `api_gateway_url`: URL do endpoint da API
- `rds_endpoint`: Endpoint do RDS PostgreSQL
- `db_secret_arn`: ARN do segredo com credenciais
- `vpc_id`: ID da VPC criada
- `lambda_function_name`: Nome da função Lambda

## Teste

```bash
# URL da API
API_URL=$(terraform output -raw api_gateway_url)

# Testar com CPF válido
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"cpf":"11144477735"}'
```

## Custos Estimados (us-east-1, uso 24/7)

- **VPC/Networking**: Gratuito (exceto NAT Gateway)
- **NAT Gateway**: ~$32/mês + $0.045/GB transferido
- **RDS db.t4g.micro**: ~$13/mês
- **Lambda**: Nível gratuito cobre uso de dev
- **Secrets Manager**: $0.40/mês por segredo
- **CloudWatch Logs**: Nível gratuito cobre uso de dev

**Total estimado (dev)**: ~$45-50/mês

**Redução de custos:**
- Desabilitar NAT Gateway: `enable_nat_gateway = false` (use VPC endpoints)
- Habilitar VPC Endpoints: `enable_vpc_endpoints = true` (~$7/mês, economiza NAT)

## Segurança

### Checklist
- ✅ RDS em subnets privadas
- ✅ Lambda em subnets privadas
- ✅ Credenciais no Secrets Manager
- ✅ Criptografia RDS habilitada
- ✅ Security Groups com least privilege
- ✅ CloudWatch Logs habilitados
- ✅ No access público ao RDS

### Melhorias para Produção
- [ ] Habilitar Multi-AZ: `db_multi_az = true`
- [ ] Aumentar retenção de backup: `db_backup_retention = 30`
- [ ] Habilitar deletion protection: `db_deletion_protection = true`
- [ ] Configurar alertas CloudWatch
- [ ] Implementar rotation de secrets
- [ ] Habilitar X-Ray tracing: `enable_xray_tracing = true`

## Troubleshooting

### Lambda timeout conectando ao RDS
- Verifique se NAT Gateway está habilitado ou VPC Endpoints configurados
- Confirme Security Groups permitem tráfego Lambda → RDS

### Erro de conexão ao RDS
```bash
# Testar conectividade de dentro da VPC
# Criar uma instância EC2 temporária na mesma VPC/subnet
```

### Custos altos de NAT
- Habilite VPC Endpoints: `enable_vpc_endpoints = true`
- Reduza logging excessivo que usa internet

## Limpeza

```bash
terraform destroy
```

**Atenção**: Backups automáticos serão perdidos se `db_skip_final_snapshot = true`

## Estrutura de Arquivos

```
infra/terraform/
├── main.tf              # Documentação da arquitetura
├── provider.tf          # Configuração do provider AWS
├── vars.tf             # Definição de variáveis
├── locals.tf           # Valores locais
├── vpc.tf              # VPC, Subnets, NAT, IGW, Routes
├── rds.tf              # RDS PostgreSQL
├── secrets.tf          # Secrets Manager
├── lambda.tf           # Lambda + Security Groups
├── iam.tf              # IAM Roles e Policies
├── api-gateway.tf      # API Gateway REST
├── outputs.tf          # Outputs
├── backend.tf          # Backend config (opcional)
├── terraform.tfvars.example  # Exemplo de variáveis
└── README.md           # Este arquivo
```

## Suporte

Para questões sobre a infraestrutura, consulte:
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-best-practices.html)
- [AWS RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)

