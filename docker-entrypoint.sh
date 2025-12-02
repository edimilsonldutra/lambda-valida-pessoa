#!/bin/bash
# Docker entrypoint script

set -e

echo ""
echo "============================================================"
echo "   Lambda Valida Pessoa - Docker Deploy Environment"
echo "============================================================"
echo ""

# Verificar se credenciais AWS estão configuradas
if [ ! -f /root/.aws/credentials ] && [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "⚠️  AVISO: Credenciais AWS não encontradas"
    echo ""
    echo "Para configurar, execute:"
    echo "  docker run -it --rm -v \$(pwd):/workspace -v ~/.aws:/root/.aws lambda-valida-pessoa aws configure"
    echo ""
    echo "Ou passe as variáveis de ambiente:"
    echo "  -e AWS_ACCESS_KEY_ID=..."
    echo "  -e AWS_SECRET_ACCESS_KEY=..."
    echo "  -e AWS_DEFAULT_REGION=us-east-1"
    echo ""
fi

# Verificar ferramentas instaladas
echo "✅ Ferramentas disponíveis:"
echo "   AWS CLI: $(aws --version)"
echo "   Terraform: $(terraform --version | head -1)"
echo "   Java: $(java -version 2>&1 | head -1)"
echo ""

# Verificar JAR
if [ -f "LambdaValidaPessoa/target/ValidaPessoa-1.0.jar" ]; then
    echo "✅ JAR compilado: $(ls -lh LambdaValidaPessoa/target/ValidaPessoa-1.0.jar | awk '{print $5}')"
else
    echo "⚠️  JAR não encontrado (pode ser necessário recompilar)"
fi
echo ""

# Verificar terraform.tfvars
if [ -f "infra/terraform/terraform.tfvars" ]; then
    echo "✅ terraform.tfvars encontrado"
else
    echo "⚠️  terraform.tfvars não encontrado"
    echo "   Execute: cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars"
fi
echo ""

echo "============================================================"
echo "   Pronto para deploy!"
echo "============================================================"
echo ""
echo "Comandos úteis:"
echo "  terraform -chdir=infra/terraform init"
echo "  terraform -chdir=infra/terraform plan"
echo "  terraform -chdir=infra/terraform apply"
echo ""

# Executar comando passado ou shell interativo
exec "$@"

