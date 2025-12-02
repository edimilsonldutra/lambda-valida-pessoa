# 🐳 Deploy Simplificado com Docker

## ⚡ Quick Start (3 passos)

### 1. Instalar Docker
- Windows/Mac: https://www.docker.com/products/docker-desktop
- Linux: `sudo apt-get install docker.io docker-compose`

### 2. Construir Imagem
```bash
# Windows
docker-build.bat

# Linux/Mac
chmod +x docker-build.sh
./docker-build.sh
```

### 3. Deploy
```bash
# Windows
docker-deploy.bat

# Linux/Mac
chmod +x docker-deploy.sh
./docker-deploy.sh
```

Dentro do container:
```bash
# Configurar AWS (se necessário)
aws configure

# Deploy
terraform -chdir=infra/terraform init
terraform -chdir=infra/terraform plan
terraform -chdir=infra/terraform apply
```

---

## ✅ O que está incluído no Docker

A imagem Docker já inclui:
- ✅ Java 21
- ✅ Maven (JAR já compilado)
- ✅ AWS CLI
- ✅ Terraform
- ✅ Todas as dependências

**Você só precisa do Docker!**

---

## 📚 Documentação Completa

Veja `DOCKER_DEPLOYMENT.md` para:
- Configuração detalhada
- Troubleshooting
- Comandos avançados
- Ambientes de desenvolvimento local (PostgreSQL, LocalStack)

---

## 🎯 Benefícios

| Antes | Agora (Docker) |
|-------|---------------|
| Instalar 4+ ferramentas | Instalar Docker |
| ~1 hora de setup | ~15 minutos |
| Problemas de versão | Sem problemas |
| Só funciona em um SO | Funciona em todos |

---

## 🔧 Arquivos Criados

- `Dockerfile` - Imagem com todas as ferramentas
- `docker-compose.yml` - Orquestração
- `docker-build.bat/sh` - Scripts de build
- `docker-deploy.bat/sh` - Scripts de deploy
- `.env.example` - Template de configuração
- `DOCKER_DEPLOYMENT.md` - Documentação completa

---

**Pronto para começar? Execute `docker-build.bat`!** 🚀

