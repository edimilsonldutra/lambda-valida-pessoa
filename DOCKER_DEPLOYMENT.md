# 🐳 Deploy com Docker - Lambda Valida Pessoa

## ✨ Vantagens da Solução Docker

### ✅ O que você NÃO precisa mais instalar localmente:
- ❌ Java 21
- ❌ Maven
- ❌ AWS CLI
- ❌ Terraform

### ✅ O que você PRECISA:
- ✅ Docker Desktop (único requisito!)
- ✅ Credenciais AWS (Access Key ID e Secret Key)

---

## 🚀 Quick Start - Deploy em 3 Passos

### 1️⃣ Instalar Docker Desktop

**Windows:**
- Baixar: https://www.docker.com/products/docker-desktop
- Instalar e iniciar o Docker Desktop
- Verificar: `docker --version`

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose

# Verificar
docker --version
```

**Mac:**
- Baixar: https://www.docker.com/products/docker-desktop
- Instalar e iniciar
- Verificar: `docker --version`

---

### 2️⃣ Construir a Imagem Docker

**Windows:**
```bash
docker-build.bat
```

**Linux/Mac:**
```bash
chmod +x docker-build.sh
./docker-build.sh
```

Isso irá:
- ✅ Compilar a aplicação Java automaticamente
- ✅ Instalar AWS CLI
- ✅ Instalar Terraform
- ✅ Preparar tudo para deploy

**Tempo:** ~5-10 minutos (primeira vez)

---

### 3️⃣ Fazer o Deploy

**Windows:**
```bash
docker-deploy.bat
```

**Linux/Mac:**
```bash
chmod +x docker-deploy.sh
./docker-deploy.sh
```

Dentro do container:

```bash
# 1. Configurar AWS (se não tiver credenciais)
aws configure

# 2. Criar terraform.tfvars (se ainda não existir)
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
# Editar: vi infra/terraform/terraform.tfvars

# 3. Fazer deploy
terraform -chdir=infra/terraform init
terraform -chdir=infra/terraform plan
terraform -chdir=infra/terraform apply
```

---

## 📁 Arquivos Docker Criados

```
projeto/
├── Dockerfile                  # Imagem com todas as ferramentas
├── docker-compose.yml         # Orquestração de containers
├── .dockerignore              # Arquivos ignorados no build
├── .env.example               # Template de variáveis de ambiente
├── docker-entrypoint.sh       # Script de inicialização
├── docker-build.bat           # Build para Windows
├── docker-build.sh            # Build para Linux/Mac
├── docker-deploy.bat          # Deploy para Windows
└── docker-deploy.sh           # Deploy para Linux/Mac
```

---

## 🔧 Configuração

### Opção 1: Usar Credenciais AWS do Host (Recomendado)

Se você já tem AWS CLI configurado localmente:

```bash
# Windows
docker-deploy.bat

# Linux/Mac
./docker-deploy.sh
```

O script automaticamente monta suas credenciais `~/.aws/` no container.

---

### Opção 2: Configurar Credenciais via Variáveis de Ambiente

1. Criar arquivo `.env`:
```bash
cp .env.example .env
```

2. Editar `.env`:
```bash
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION=us-east-1
```

3. Executar:
```bash
docker-compose run --rm deploy bash
```

---

### Opção 3: Configurar Dentro do Container

```bash
# Entrar no container
docker-compose run --rm deploy bash

# Configurar AWS
aws configure
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region: us-east-1
# Default output: json
```

---

## 📋 Comandos Úteis

### Build e Deploy

```bash
# Construir imagem
docker-compose build deploy

# Executar container interativo
docker-compose run --rm deploy bash

# Executar comando específico
docker-compose run --rm deploy terraform -chdir=infra/terraform init

# Ver logs do container
docker-compose logs -f deploy
```

---

### Dentro do Container

```bash
# Verificar ferramentas instaladas
aws --version
terraform --version
java -version

# Verificar credenciais AWS
aws sts get-caller-identity

# Terraform - inicializar
terraform -chdir=infra/terraform init

# Terraform - planejar
terraform -chdir=infra/terraform plan

# Terraform - aplicar
terraform -chdir=infra/terraform apply

# Terraform - destruir
terraform -chdir=infra/terraform destroy

# Sair do container
exit
```

---

### Gerenciamento de Containers

```bash
# Listar containers rodando
docker-compose ps

# Parar todos os containers
docker-compose down

# Remover volumes (limpar tudo)
docker-compose down -v

# Ver imagens
docker images

# Remover imagem
docker rmi lambda-valida-pessoa:latest
```

---

## 🧪 Ambiente de Desenvolvimento Local (Opcional)

O `docker-compose.yml` inclui serviços opcionais para desenvolvimento:

### PostgreSQL Local

```bash
# Iniciar PostgreSQL
docker-compose up -d postgres

# Conectar ao PostgreSQL
docker-compose exec postgres psql -U postgres -d valida_pessoa

# Ver logs
docker-compose logs -f postgres
```

**Conexão:**
- Host: `localhost`
- Port: `5432`
- Database: `valida_pessoa`
- Username: `postgres`
- Password: `postgres123`

---

### LocalStack (AWS Local)

Para testar sem usar AWS real:

```bash
# Iniciar LocalStack
docker-compose up -d localstack

# Ver logs
docker-compose logs -f localstack

# Executar comandos AWS contra LocalStack
aws --endpoint-url=http://localhost:4566 s3 ls
```

---

## 🔄 Workflow Completo

### Primeira Vez (Setup Inicial)

```bash
# 1. Instalar Docker Desktop
# https://www.docker.com/products/docker-desktop

# 2. Clonar/abrir projeto
cd lambda-valida-pessoa

# 3. Criar arquivo de configuração
cp .env.example .env
# Editar .env com suas credenciais (ou usar ~/.aws/)

# 4. Criar terraform.tfvars
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
# Editar: jwt_secret, db_password

# 5. Construir imagem Docker
docker-build.bat  # Windows
# OU
./docker-build.sh  # Linux/Mac

# 6. Fazer deploy
docker-deploy.bat  # Windows
# OU
./docker-deploy.sh  # Linux/Mac
```

---

### Deploy Subsequente

```bash
# Apenas executar
docker-deploy.bat  # Windows
./docker-deploy.sh  # Linux/Mac

# Dentro do container
terraform -chdir=infra/terraform plan
terraform -chdir=infra/terraform apply
```

---

### Atualizar Código e Re-deploy

```bash
# 1. Editar código Java em LambdaValidaPessoa/src/

# 2. Reconstruir imagem (recompila o JAR)
docker-compose build deploy

# 3. Deploy
docker-deploy.bat
# Dentro do container:
terraform -chdir=infra/terraform apply
```

---

## 🐛 Troubleshooting

### Erro: "Cannot connect to Docker daemon"

**Problema:** Docker não está rodando

**Solução:**
- Windows: Iniciar Docker Desktop
- Linux: `sudo systemctl start docker`

---

### Erro: "denied: requested access to the resource is denied"

**Problema:** Permissões Docker (Linux)

**Solução:**
```bash
sudo usermod -aG docker $USER
# Fazer logout e login novamente
```

---

### Erro: "No space left on device"

**Problema:** Disco cheio

**Solução:**
```bash
# Limpar imagens não utilizadas
docker system prune -a

# Limpar volumes
docker volume prune
```

---

### Erro: AWS "The security token included in the request is invalid"

**Problema:** Credenciais AWS inválidas ou expiradas

**Solução:**
```bash
# Dentro do container
aws configure
# Informar novas credenciais
```

---

### Build Muito Lento

**Problema:** Download de dependências Maven

**Solução:**
- É normal na primeira vez (~5-10 min)
- Builds subsequentes são mais rápidos (cache)
- Usar `docker-compose build --no-cache` apenas se necessário

---

## 📊 Comparação: Local vs Docker

| Aspecto | Instalação Local | Docker |
|---------|-----------------|--------|
| **Ferramentas a instalar** | Java, Maven, AWS CLI, Terraform | Apenas Docker |
| **Tempo de setup** | ~1 hora | ~15 minutos |
| **Problemas de versão** | Possível | Não |
| **Funciona em qualquer SO** | Requer ajustes | Sim |
| **Isolamento** | Não | Sim |
| **Reprodutibilidade** | Baixa | Alta |
| **Tamanho** | ~2GB | ~1.5GB |

---

## 💡 Melhores Práticas

### 1. Credenciais AWS

✅ **Recomendado:**
- Usar volume mount de `~/.aws/` (credenciais do host)
- Ou usar IAM roles (se rodando em EC2)

❌ **Evitar:**
- Hardcoded no código
- Commitar no Git

---

### 2. Persistência de Dados

O `docker-compose.yml` já configura volumes para:
- ✅ Estado do Terraform (`.terraform/`)
- ✅ Dados do PostgreSQL (se usar local)

---

### 3. Desenvolvimento

Para edição em tempo real:
```bash
# Volumes já montados em docker-compose.yml
# Edite os arquivos localmente
# Eles são refletidos automaticamente no container
```

---

### 4. CI/CD

Exemplo para GitHub Actions:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker
        run: ./docker-build.sh
      
      - name: Deploy
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          docker-compose run --rm deploy bash -c "
            terraform -chdir=infra/terraform init
            terraform -chdir=infra/terraform apply -auto-approve
          "
```

---

## 🎯 Checklist Completo

### Pré-requisitos
- [ ] Docker Desktop instalado e rodando
- [ ] Credenciais AWS (Access Key ID + Secret Key)
- [ ] Arquivo `.env` criado (ou `~/.aws/credentials`)
- [ ] Arquivo `terraform.tfvars` criado e editado

### Build
- [ ] `docker-build.bat` executado com sucesso
- [ ] Imagem `lambda-valida-pessoa:latest` criada
- [ ] JAR compilado dentro da imagem

### Deploy
- [ ] Container iniciado com `docker-deploy.bat`
- [ ] Credenciais AWS configuradas/verificadas
- [ ] Terraform init executado
- [ ] Terraform plan revisado
- [ ] Terraform apply executado
- [ ] API testada com sucesso

---

## 🚀 Vantagens da Solução Docker

### ✅ Antes (Instalação Local)
```
Problemas:
- Instalar Java 21 ❌
- Instalar Maven ❌
- Instalar AWS CLI ❌
- Instalar Terraform ❌
- Configurar PATH ❌
- Conflitos de versão ❌
- Funciona só no meu PC ❌

Tempo: ~1-2 horas
```

### ✅ Agora (Com Docker)
```
Solução:
- Instalar Docker ✅
- docker-build.bat ✅
- docker-deploy.bat ✅

Tempo: ~15 minutos
Funciona em: Windows, Mac, Linux ✅
```

---

## 📚 Próximos Passos

1. **Instalar Docker Desktop**
2. **Executar**: `docker-build.bat`
3. **Configurar**: Criar `.env` ou usar `~/.aws/`
4. **Editar**: `infra/terraform/terraform.tfvars`
5. **Deploy**: `docker-deploy.bat`

---

## 📞 Suporte

- Docker Docs: https://docs.docker.com
- Docker Compose: https://docs.docker.com/compose
- Troubleshooting: https://docs.docker.com/desktop/troubleshoot

---

**Criado em:** 2025-12-02  
**Versão:** 1.0  
**Compatibilidade:** Windows, Linux, macOS

