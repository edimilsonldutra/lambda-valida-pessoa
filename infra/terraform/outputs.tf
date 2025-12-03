# API Gateway URL
output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_stage.stage.invoke_url}/auth"
}

# API Gateway ID
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

# Lambda Function Name
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.valida_pessoa.function_name
}

# Lambda Function ARN
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.valida_pessoa.arn
}

# Lambda Function Invoke ARN
output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.valida_pessoa.invoke_arn
}

# CloudWatch Log Group Name
output "lambda_log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

# API Gateway Log Group Name
output "api_gateway_log_group_name" {
  description = "Name of the API Gateway CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gateway_logs.name
}

# Region
output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

# Environment
output "environment" {
  description = "Environment name"
  value       = var.environment
}

# Test Command
output "test_command" {
  description = "Command to test the API"
  value       = "curl -X POST ${aws_api_gateway_stage.stage.invoke_url}/auth -H 'Content-Type: application/json' -d '{\"cpf\":\"11144477735\"}'"
}

# RDS Endpoint
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}

# RDS Security Group ID
output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

# DB Secret ARN
output "db_secret_arn" {
  description = "ARN of the DB credentials secret"
  value       = aws_secretsmanager_secret.db.arn
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}

# Lambda Security Group
output "lambda_security_group_id" {
  description = "Lambda Security Group ID"
  value       = aws_security_group.lambda_sg.id
}

# ========================================
# CI/CD Outputs - GitHub Actions Setup
# ========================================

# Development Environment
output "github_secret_aws_access_key_id_dev" {
  description = "AWS Access Key ID for GitHub Actions - Development (Add this to GitHub Secrets as AWS_ACCESS_KEY_ID_DEV)"
  value       = aws_iam_access_key.github_actions_dev.id
  sensitive   = false
}

output "github_secret_aws_secret_access_key_dev" {
  description = "AWS Secret Access Key for GitHub Actions - Development (Add this to GitHub Secrets as AWS_SECRET_ACCESS_KEY_DEV)"
  value       = aws_iam_access_key.github_actions_dev.secret
  sensitive   = true
}

output "github_secret_s3_deployment_bucket_dev" {
  description = "S3 Deployment Bucket for Development (Add this to GitHub Secrets as S3_DEPLOYMENT_BUCKET_DEV)"
  value       = aws_s3_bucket.deployment_dev.id
  sensitive   = false
}

# Production Environment
output "github_secret_aws_access_key_id_prod" {
  description = "AWS Access Key ID for GitHub Actions - Production (Add this to GitHub Secrets as AWS_ACCESS_KEY_ID_PROD)"
  value       = aws_iam_access_key.github_actions_prod.id
  sensitive   = false
}

output "github_secret_aws_secret_access_key_prod" {
  description = "AWS Secret Access Key for GitHub Actions - Production (Add this to GitHub Secrets as AWS_SECRET_ACCESS_KEY_PROD)"
  value       = aws_iam_access_key.github_actions_prod.secret
  sensitive   = true
}

output "github_secret_s3_deployment_bucket_prod" {
  description = "S3 Deployment Bucket for Production (Add this to GitHub Secrets as S3_DEPLOYMENT_BUCKET_PROD)"
  value       = aws_s3_bucket.deployment_prod.id
  sensitive   = false
}

# Summary output for easy copy-paste
output "github_actions_setup_summary" {
  description = "Summary of all GitHub Secrets to configure"
  value = <<-EOT

    ========================================
    🔐 GitHub Secrets Configuration
    ========================================

    Go to: GitHub Repository → Settings → Secrets and variables → Actions

    Add the following Repository Secrets:

    📌 Development Environment:
    ---------------------------
    Name: AWS_ACCESS_KEY_ID_DEV
    Value: ${aws_iam_access_key.github_actions_dev.id}

    Name: AWS_SECRET_ACCESS_KEY_DEV
    Value: <sensitive - use: terraform output -raw github_secret_aws_secret_access_key_dev>

    Name: S3_DEPLOYMENT_BUCKET_DEV
    Value: ${aws_s3_bucket.deployment_dev.id}

    📌 Production Environment:
    --------------------------
    Name: AWS_ACCESS_KEY_ID_PROD
    Value: ${aws_iam_access_key.github_actions_prod.id}

    Name: AWS_SECRET_ACCESS_KEY_PROD
    Value: <sensitive - use: terraform output -raw github_secret_aws_secret_access_key_prod>

    Name: S3_DEPLOYMENT_BUCKET_PROD
    Value: ${aws_s3_bucket.deployment_prod.id}

    ========================================
    💡 To view sensitive values:
    ========================================
    terraform output -raw github_secret_aws_secret_access_key_dev
    terraform output -raw github_secret_aws_secret_access_key_prod

  EOT
  sensitive = false
}

# Lambda Security Group (continuing from above)
output "lambda_security_group_id_continued" {
  description = "Lambda Security Group ID"
  value       = aws_security_group.lambda_sg.id
}

