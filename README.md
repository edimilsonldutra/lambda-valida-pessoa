# 🚀 AWS Lambda - Validação de CPF e Autenticação JWT

## ✨ Visão Geral

Sistema completo de autenticação para validação de CPF de clientes brasileiros, consulta em base de dados DynamoDB e geração de tokens JWT para acesso a APIs protegidas.

### 🎯 Funcionalidades Principais

✅ **Validação de CPF** - Algoritmo completo de validação de CPF brasileiro  
✅ **Consulta de Cliente** - Busca e validação de status no DynamoDB  
✅ **Geração de JWT** - Tokens seguros com expiração configurável  
✅ **API REST** - Endpoint HTTP via API Gateway  
✅ **Infraestrutura como Código** - Deploy completo via Terraform  
✅ **Serverless** - Zero servidores para gerenciar  

---

## 📚 Documentação

| Documento | Descrição |
|-----------|-----------|
| 📖 [README_NOVO.md](README_NOVO.md) | Documentação técnica completa |
| 🛠️ [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) | Tutorial passo a passo de instalação |
| 💻 [API_EXAMPLES.md](API_EXAMPLES.md) | Exemplos de código em várias linguagens |
| ⚡ [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Referência rápida de comandos |
| 📦 [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Resumo completo do projeto |

---

## 🚀 Deploy em 5 Minutos

### Windows

```bash
# 1. Build
cd HelloWorldFunction
mvn clean package
cd ..

# 2. Configure
cd terraform
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars

# 3. Deploy
terraform init
terraform apply

# Ou use o script automático:
deploy.bat
```

### Linux/Mac

```bash
# 1. Build
cd HelloWorldFunction && mvn clean package && cd ..

# 2. Configure
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 3. Deploy
terraform init && terraform apply

# Ou use o script automático:
chmod +x deploy.sh
./deploy.sh
```

---

## 📡 Uso da API

### Endpoint

```
POST https://{api-gateway-url}/dev/auth
```

### Request

```json
{
  "cpf": "11144477735"
}
```

### Response (200 - Sucesso)

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJjcGYiOiIxMTE0NDQ3NzczNSIsIm5hbWUiOiJKb8OjbyBTaWx2YSIsImVtYWlsIjoiam9hby5zaWx2YUBleGFtcGxlLmNvbSIsInN0YXR1cyI6IkFDVElWRSIsInN1YiI6IjExMTQ0NDc3NzM1IiwiaWF0IjoxNzAxMzQ1NjAwLCJleHAiOjE3MDEzNDkyMDB9.signature",
  "customer": {
    "cpf": "11144477735",
    "name": "João Silva",
    "email": "joao.silva@example.com",
    "status": "ACTIVE"
  }
}
```

### Códigos de Erro

| Código | Descrição |
|--------|-----------|
| 400 | CPF inválido |
| 403 | Cliente com status inativo |
| 404 | Cliente não encontrado |
| 500 | Erro interno do servidor |

---

## 💾 CPFs de Teste

Após o deploy, você terá 3 clientes de exemplo:

| CPF | Nome | Status | Resultado |
|-----|------|--------|-----------|
| 11144477735 | João Silva | ✅ ACTIVE | Token JWT |
| 52998224725 | Maria Santos | ✅ ACTIVE | Token JWT |
| 70987206109 | Pedro Oliveira | ❌ INACTIVE | Erro 403 |

---

## 🏗️ Arquitetura

```
┌─────────────┐
│   Cliente   │
└──────┬──────┘
       │ POST /auth
       ▼
┌──────────────────┐
│  API Gateway     │
│  (REST API)      │
└──────┬───────────┘
       │ Invoca
       ▼
┌──────────────────┐      ┌──────────────┐
│  Lambda Function │─────▶│  DynamoDB    │
│  (Java 21)       │      │  (Customers) │
└──────┬───────────┘      └──────────────┘
       │
       ▼
┌──────────────────┐
│  CloudWatch      │
│  (Logs)          │
└──────────────────┘
```

---

## 📂 Estrutura do Projeto

```
lambda-valida-pessoa/
├── HelloWorldFunction/           # Código Java
│   ├── src/
│   │   ├── main/java/helloworld/
│   │   │   ├── ValidaPessoaFunction.java    # Handler
│   │   │   ├── model/                       # DTOs
│   │   │   │   ├── AuthRequest.java
│   │   │   │   ├── AuthResponse.java
│   │   │   │   └── Customer.java
│   │   │   └── service/                     # Serviços
│   │   │       ├── CPFValidator.java
│   │   │       ├── CustomerService.java
│   │   │       └── JWTService.java
│   │   └── test/                            # Testes
│   ├── Dockerfile
│   └── pom.xml
│
├── terraform/                     # Infraestrutura
│   ├── main.tf                   # Config principal
│   ├── seed-data.tf             # Dados exemplo
│   └── terraform.tfvars.example
│
├── scripts/                       # Utilitários
│   ├── add-customer.sh
│   └── add-customer.bat
│
├── events/                        # Eventos teste
│   └── auth-request.json
│
├── docs/                          # Documentação
│   ├── README_NOVO.md
│   ├── INSTALLATION_GUIDE.md
│   ├── API_EXAMPLES.md
│   ├── QUICK_REFERENCE.md
│   └── PROJECT_SUMMARY.md
│
├── deploy.sh                      # Deploy Linux/Mac
├── deploy.bat                     # Deploy Windows
└── README.md                      # Este arquivo
```

---

## 🔧 Tecnologias

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **Java** | 21 | Runtime Lambda |
| **Maven** | 3.8+ | Build |
| **JJWT** | 0.12.6 | JWT tokens |
| **AWS SDK** | 2.29.32 | DynamoDB |
| **Gson** | 2.11.0 | JSON parsing |
| **Terraform** | 1.0+ | IaC |
| **JUnit** | 4.13.2 | Testes |

---

## 💰 Custos

### AWS Free Tier
- Lambda: 1M requests/mês grátis
- DynamoDB: 25GB + 25 WCU/RCU grátis
- API Gateway: 1M requests/mês grátis

### Após Free Tier
- ~$0.0001 por requisição
- Custo estimado: **Quase zero** para baixo/médio volume

---

## 🧪 Testes

### Teste Manual

```bash
# Cliente ativo (sucesso)
curl -X POST https://YOUR_API_URL/dev/auth \
  -H 'Content-Type: application/json' \
  -d '{"cpf":"11144477735"}'

# CPF inválido (erro 400)
curl -X POST https://YOUR_API_URL/dev/auth \
  -H 'Content-Type: application/json' \
  -d '{"cpf":"12345678901"}'

# Cliente inativo (erro 403)
curl -X POST https://YOUR_API_URL/dev/auth \
  -H 'Content-Type: application/json' \
  -d '{"cpf":"70987206109"}'
```

### Testes Unitários

```bash
cd HelloWorldFunction
mvn test
```

---

## 📊 Monitoramento

### Ver Logs em Tempo Real

```bash
aws logs tail /aws/lambda/valida-pessoa-dev --follow
```

### Métricas

Acesse o AWS Console:
1. Lambda > valida-pessoa-dev
2. Tab "Monitor"
3. Veja: Invocations, Duration, Errors, Throttles

---

## 🔄 Atualização

```bash
# 1. Altere o código em HelloWorldFunction/
# 2. Rebuild
cd HelloWorldFunction && mvn clean package && cd ..

# 3. Redeploy
cd terraform && terraform apply
```

---

## 🗑️ Remover Recursos

```bash
cd terraform
terraform destroy
```

⚠️ **ATENÇÃO**: Isso removerá TODOS os recursos e dados!

---

## 🔐 Segurança

### ✅ Implementado
- Validação rigorosa de CPF
- JWT com assinatura HS256
- IAM roles com least privilege
- CORS configurado
- Logs de auditoria

### 🔜 Para Produção
- [ ] JWT_SECRET no Secrets Manager
- [ ] API Gateway com autenticação
- [ ] Rate limiting
- [ ] WAF
- [ ] DynamoDB backup
- [ ] CloudWatch alarmes

---

## ❓ Troubleshooting

### Build Falha

```bash
cd HelloWorldFunction
mvn clean install -U
```

### Terraform State Lock

```bash
terraform force-unlock LOCK_ID
```

### Lambda não Invoca

```bash
# Ver logs
aws logs tail /aws/lambda/valida-pessoa-dev --follow

# Verificar função
aws lambda get-function --function-name valida-pessoa-dev
```

---

## 📞 Suporte

1. Consulte a documentação em `docs/`
2. Verifique CloudWatch Logs
3. Revise o [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)
4. Consulte [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

## 📚 Links Úteis

- [AWS Lambda Docs](https://docs.aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [JJWT Documentation](https://github.com/jwtk/jjwt)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/dynamodb/latest/developerguide/best-practices.html)

---

## 🎓 Projeto FIAP

Desenvolvido como parte do programa **FIAP - Fase 3**

### Objetivos Atingidos

✅ Validação de CPF do cliente  
✅ Consulta de existência e status na base de dados  
✅ Geração de token JWT válido  
✅ Infraestrutura via Terraform  
✅ Código bem estruturado e testado  
✅ Documentação completa  

---

## 📄 Licença

Projeto educacional - FIAP 2024

---

## ✨ Status

**🎉 PRONTO PARA USO!**

Todos os componentes implementados e testados:
- ✅ Código Java completo
- ✅ Testes unitários
- ✅ Infraestrutura Terraform
- ✅ Documentação detalhada
- ✅ Scripts de deploy
- ✅ Dados de exemplo

---

## 🚀 Começar Agora

```bash
# Clone ou navegue até o projeto
cd lambda-valida-pessoa

# Execute o deploy automático
# Windows:
deploy.bat

# Linux/Mac:
./deploy.sh
```

**Em 5 minutos sua API estará no ar!** 🎉

---

**Desenvolvido com ❤️ para FIAP**

test
