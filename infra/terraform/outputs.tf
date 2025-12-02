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
