#!/bin/bash

# ========================================
# Setup GitHub Secrets from Terraform
# ========================================
# This script helps you configure GitHub Secrets automatically
# after running terraform apply
# ========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🔐 GitHub Secrets Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Error: terraform is not installed${NC}"
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: GitHub CLI (gh) is not installed${NC}"
    echo -e "${YELLOW}   Install it from: https://cli.github.com/${NC}"
    echo -e "${YELLOW}   Or configure secrets manually${NC}"
    MANUAL_MODE=true
else
    MANUAL_MODE=false
fi

# Navigate to terraform directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../infra/terraform"

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo -e "${RED}❌ Error: Terraform directory not found at $TERRAFORM_DIR${NC}"
    exit 1
fi

cd "$TERRAFORM_DIR"

echo -e "${GREEN}📂 Working directory: $TERRAFORM_DIR${NC}"
echo ""

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${RED}❌ Error: terraform.tfstate not found${NC}"
    echo -e "${YELLOW}   Please run 'terraform apply' first${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Retrieving outputs from Terraform...${NC}"
echo ""

# Get outputs from terraform
ACCESS_KEY_DEV=$(terraform output -raw github_secret_aws_access_key_id_dev 2>/dev/null || echo "")
SECRET_KEY_DEV=$(terraform output -raw github_secret_aws_secret_access_key_dev 2>/dev/null || echo "")
BUCKET_DEV=$(terraform output -raw github_secret_s3_deployment_bucket_dev 2>/dev/null || echo "")

ACCESS_KEY_PROD=$(terraform output -raw github_secret_aws_access_key_id_prod 2>/dev/null || echo "")
SECRET_KEY_PROD=$(terraform output -raw github_secret_aws_secret_access_key_prod 2>/dev/null || echo "")
BUCKET_PROD=$(terraform output -raw github_secret_s3_deployment_bucket_prod 2>/dev/null || echo "")

# Validate outputs
if [ -z "$ACCESS_KEY_DEV" ] || [ -z "$SECRET_KEY_DEV" ] || [ -z "$BUCKET_DEV" ]; then
    echo -e "${RED}❌ Error: Could not retrieve development outputs${NC}"
    echo -e "${YELLOW}   Make sure cicd-resources.tf is applied${NC}"
    exit 1
fi

if [ -z "$ACCESS_KEY_PROD" ] || [ -z "$SECRET_KEY_PROD" ] || [ -z "$BUCKET_PROD" ]; then
    echo -e "${RED}❌ Error: Could not retrieve production outputs${NC}"
    echo -e "${YELLOW}   Make sure cicd-resources.tf is applied${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Successfully retrieved all secrets${NC}"
echo ""

# Manual mode - display secrets for copy-paste
if [ "$MANUAL_MODE" = true ]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}📋 Manual Configuration${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Go to: GitHub Repository → Settings → Secrets and variables → Actions${NC}"
    echo ""

    echo -e "${GREEN}📌 Development Environment Secrets:${NC}"
    echo -e "${BLUE}-----------------------------------${NC}"
    echo ""
    echo -e "Name:  ${YELLOW}AWS_ACCESS_KEY_ID_DEV${NC}"
    echo -e "Value: ${GREEN}$ACCESS_KEY_DEV${NC}"
    echo ""
    echo -e "Name:  ${YELLOW}AWS_SECRET_ACCESS_KEY_DEV${NC}"
    echo -e "Value: ${GREEN}$SECRET_KEY_DEV${NC}"
    echo ""
    echo -e "Name:  ${YELLOW}S3_DEPLOYMENT_BUCKET_DEV${NC}"
    echo -e "Value: ${GREEN}$BUCKET_DEV${NC}"
    echo ""

    echo -e "${GREEN}📌 Production Environment Secrets:${NC}"
    echo -e "${BLUE}-----------------------------------${NC}"
    echo ""
    echo -e "Name:  ${YELLOW}AWS_ACCESS_KEY_ID_PROD${NC}"
    echo -e "Value: ${GREEN}$ACCESS_KEY_PROD${NC}"
    echo ""
    echo -e "Name:  ${YELLOW}AWS_SECRET_ACCESS_KEY_PROD${NC}"
    echo -e "Value: ${GREEN}$SECRET_KEY_PROD${NC}"
    echo ""
    echo -e "Name:  ${YELLOW}S3_DEPLOYMENT_BUCKET_PROD${NC}"
    echo -e "Value: ${GREEN}$BUCKET_PROD${NC}"
    echo ""

    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Copy these values to GitHub Secrets${NC}"
    echo -e "${BLUE}========================================${NC}"

    # Save to file
    OUTPUT_FILE="$SCRIPT_DIR/github-secrets.txt"
    cat > "$OUTPUT_FILE" << EOF
========================================
GitHub Secrets Configuration
Generated: $(date)
========================================

Development Environment:
------------------------
AWS_ACCESS_KEY_ID_DEV=$ACCESS_KEY_DEV
AWS_SECRET_ACCESS_KEY_DEV=$SECRET_KEY_DEV
S3_DEPLOYMENT_BUCKET_DEV=$BUCKET_DEV

Production Environment:
-----------------------
AWS_ACCESS_KEY_ID_PROD=$ACCESS_KEY_PROD
AWS_SECRET_ACCESS_KEY_PROD=$SECRET_KEY_PROD
S3_DEPLOYMENT_BUCKET_PROD=$BUCKET_PROD

========================================
⚠️  IMPORTANT: Keep this file secure!
Delete it after configuring GitHub Secrets
========================================
EOF

    echo ""
    echo -e "${GREEN}💾 Secrets saved to: $OUTPUT_FILE${NC}"
    echo -e "${YELLOW}⚠️  Remember to delete this file after use!${NC}"

else
    # Automatic mode using gh CLI
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}🤖 Automatic Configuration with GitHub CLI${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  You are not authenticated with GitHub CLI${NC}"
        echo -e "${YELLOW}   Run: gh auth login${NC}"
        exit 1
    fi

    # Get repository info
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")

    if [ -z "$REPO" ]; then
        echo -e "${RED}❌ Error: Could not determine repository${NC}"
        echo -e "${YELLOW}   Make sure you are in a git repository${NC}"
        exit 1
    fi

    echo -e "${GREEN}📦 Repository: $REPO${NC}"
    echo ""

    # Confirm before setting secrets
    echo -e "${YELLOW}⚠️  This will set the following secrets in $REPO:${NC}"
    echo -e "   - AWS_ACCESS_KEY_ID_DEV"
    echo -e "   - AWS_SECRET_ACCESS_KEY_DEV"
    echo -e "   - S3_DEPLOYMENT_BUCKET_DEV"
    echo -e "   - AWS_ACCESS_KEY_ID_PROD"
    echo -e "   - AWS_SECRET_ACCESS_KEY_PROD"
    echo -e "   - S3_DEPLOYMENT_BUCKET_PROD"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}❌ Cancelled by user${NC}"
        exit 0
    fi

    echo ""
    echo -e "${BLUE}🔧 Setting secrets...${NC}"

    # Set development secrets
    echo -e "${GREEN}Setting AWS_ACCESS_KEY_ID_DEV...${NC}"
    echo "$ACCESS_KEY_DEV" | gh secret set AWS_ACCESS_KEY_ID_DEV

    echo -e "${GREEN}Setting AWS_SECRET_ACCESS_KEY_DEV...${NC}"
    echo "$SECRET_KEY_DEV" | gh secret set AWS_SECRET_ACCESS_KEY_DEV

    echo -e "${GREEN}Setting S3_DEPLOYMENT_BUCKET_DEV...${NC}"
    echo "$BUCKET_DEV" | gh secret set S3_DEPLOYMENT_BUCKET_DEV

    # Set production secrets
    echo -e "${GREEN}Setting AWS_ACCESS_KEY_ID_PROD...${NC}"
    echo "$ACCESS_KEY_PROD" | gh secret set AWS_ACCESS_KEY_ID_PROD

    echo -e "${GREEN}Setting AWS_SECRET_ACCESS_KEY_PROD...${NC}"
    echo "$SECRET_KEY_PROD" | gh secret set AWS_SECRET_ACCESS_KEY_PROD

    echo -e "${GREEN}Setting S3_DEPLOYMENT_BUCKET_PROD...${NC}"
    echo "$BUCKET_PROD" | gh secret set S3_DEPLOYMENT_BUCKET_PROD

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ All secrets configured successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # Verify
    echo -e "${BLUE}🔍 Verifying secrets...${NC}"
    gh secret list
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Verify secrets in GitHub: Repository → Settings → Secrets"
echo -e "2. Push changes to trigger CI/CD pipeline"
echo -e "3. Check GitHub Actions tab for workflow runs"
echo ""

