#!/bin/bash

# ============================================================================
# Deploy Script with New Relic Integration
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ValidaPessoa Lambda - Deploy${NC}"
echo -e "${BLUE}  With New Relic Monitoring${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}ERROR: Java is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Java found${NC}"

# Check Maven
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}ERROR: Maven is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Maven found${NC}"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: Terraform is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform found${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}ERROR: AWS CLI is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS CLI found${NC}"

echo ""

# ============================================================================
# Step 1: Build Lambda
# ============================================================================

echo -e "${BLUE}Step 1: Building Lambda function...${NC}"
cd LambdaValidaPessoa

echo "Running Maven clean package..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Maven build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Lambda JAR built successfully${NC}"
ls -lh target/ValidaPessoa-1.0.jar
echo ""

cd ..

# ============================================================================
# Step 2: Validate New Relic Configuration
# ============================================================================

echo -e "${BLUE}Step 2: Validating New Relic configuration...${NC}"

if [ -z "$NEW_RELIC_LICENSE_KEY" ]; then
    echo -e "${YELLOW}WARNING: NEW_RELIC_LICENSE_KEY environment variable is not set${NC}"
    echo -e "${YELLOW}New Relic monitoring will not be enabled${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓ NEW_RELIC_LICENSE_KEY is set${NC}"
fi

echo ""

# ============================================================================
# Step 3: Deploy Infrastructure
# ============================================================================

echo -e "${BLUE}Step 3: Deploying infrastructure with Terraform...${NC}"
cd infra/terraform

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${RED}Please edit terraform.tfvars with your configuration${NC}"
    exit 1
fi

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Terraform init failed${NC}"
    exit 1
fi

# Validate Terraform
echo "Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Terraform validation failed${NC}"
    exit 1
fi

# Format check
echo "Checking Terraform formatting..."
terraform fmt -check

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}WARNING: Terraform files are not formatted. Running fmt...${NC}"
    terraform fmt -recursive
fi

# Plan
echo "Creating Terraform plan..."
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Terraform plan failed${NC}"
    exit 1
fi

# Apply
echo -e "${YELLOW}Ready to apply Terraform changes${NC}"
read -p "Continue with apply? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

terraform apply tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Terraform apply failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Infrastructure deployed successfully${NC}"
echo ""

# ============================================================================
# Step 4: Get Outputs
# ============================================================================

echo -e "${BLUE}Step 4: Retrieving deployment information...${NC}"

API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "Not available")
LAMBDA_ARN=$(terraform output -raw lambda_function_arn 2>/dev/null || echo "Not available")

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}API Gateway URL:${NC} $API_URL"
echo -e "${BLUE}Lambda ARN:${NC} $LAMBDA_ARN"
echo ""

# ============================================================================
# Step 5: Test Endpoint
# ============================================================================

if [ "$API_URL" != "Not available" ]; then
    echo -e "${BLUE}Step 5: Testing endpoint...${NC}"
    echo ""

    TEST_CPF="11144477735"

    echo "Sending test request with CPF: $TEST_CPF"

    RESPONSE=$(curl -s -X POST "$API_URL/auth" \
        -H "Content-Type: application/json" \
        -d "{\"cpf\":\"$TEST_CPF\"}" \
        -w "\nHTTP_STATUS:%{http_code}")

    HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d':' -f2)
    BODY=$(echo "$RESPONSE" | grep -v "HTTP_STATUS")

    echo ""
    echo "Response (HTTP $HTTP_STATUS):"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
    echo ""

    if [ "$HTTP_STATUS" == "200" ]; then
        echo -e "${GREEN}✓ API is working!${NC}"
    else
        echo -e "${YELLOW}⚠ API returned status $HTTP_STATUS${NC}"
    fi
fi

echo ""

# ============================================================================
# Step 6: New Relic Dashboard Links
# ============================================================================

if [ -n "$NEW_RELIC_LICENSE_KEY" ]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  New Relic Monitoring${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Your application is now being monitored by New Relic!"
    echo ""
    echo "View your dashboard at:"
    echo -e "${BLUE}https://one.newrelic.com${NC}"
    echo ""
    echo "Application Name: ValidaPessoa Lambda"
    echo ""
    echo "Key Metrics to Monitor:"
    echo "  • Response Time"
    echo "  • Error Rate"
    echo "  • Throughput"
    echo "  • Memory Usage"
    echo "  • Database Query Performance"
    echo ""
fi

# ============================================================================
# Cleanup
# ============================================================================

cd ../..

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

