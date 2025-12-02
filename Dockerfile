# Multi-stage Dockerfile para Lambda Valida Pessoa
# Inclui todas as ferramentas necessárias: Maven, AWS CLI, Terraform

# ============================================================================
# Stage 1: Build da aplicação Java
# ============================================================================
FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /build

# Copiar POM primeiro para cache de dependências
COPY LambdaValidaPessoa/pom.xml ./
RUN mvn dependency:go-offline -B

# Copiar código fonte e compilar
COPY LambdaValidaPessoa/src ./src
RUN mvn clean package -DskipTests

# Verificar se o JAR foi criado
RUN ls -lh target/*.jar

# ============================================================================
# Stage 2: Imagem final com todas as ferramentas para deploy
# ============================================================================
FROM alpine:3.19

# Metadata
LABEL maintainer="FIAP"
LABEL description="Lambda Valida Pessoa - Deploy Environment"
LABEL version="1.0"

# Instalar ferramentas base
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    unzip \
    jq \
    python3 \
    py3-pip \
    ca-certificates \
    openssl

# ============================================================================
# Instalar AWS CLI v2
# ============================================================================
RUN apk add --no-cache \
    gcompat \
    && cd /tmp \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

# Verificar instalação AWS CLI
RUN aws --version

# ============================================================================
# Instalar Terraform
# ============================================================================
ARG TERRAFORM_VERSION=1.6.6
RUN cd /tmp \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Verificar instalação Terraform
RUN terraform --version

# ============================================================================
# Instalar Java 21 (para testes locais, se necessário)
# ============================================================================
RUN apk add --no-cache openjdk21-jre

# Verificar instalação Java
RUN java -version

# ============================================================================
# Configurar diretório de trabalho
# ============================================================================
WORKDIR /workspace

# Copiar o JAR compilado do stage anterior
COPY --from=builder /build/target/*.jar ./LambdaValidaPessoa/target/

# Copiar arquivos do projeto
COPY infra ./infra
COPY scripts ./scripts
COPY *.sh ./
COPY *.bat ./
COPY samconfig.toml ./
COPY template.yaml ./

# Criar diretórios necessários
RUN mkdir -p /root/.aws

# Tornar scripts executáveis
RUN chmod +x *.sh || true

# ============================================================================
# Script de inicialização
# ============================================================================
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]

# ============================================================================
# Verificar todas as ferramentas instaladas
# ============================================================================
RUN echo "=== Ferramentas Instaladas ===" \
    && echo "AWS CLI: $(aws --version)" \
    && echo "Terraform: $(terraform --version | head -1)" \
    && echo "Java: $(java -version 2>&1 | head -1)" \
    && echo "JAR: $(ls -lh LambdaValidaPessoa/target/*.jar 2>/dev/null || echo 'Not found')"

