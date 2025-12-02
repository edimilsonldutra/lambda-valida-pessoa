# Local values for resource naming and tagging
locals {
  # Resource names
  name_prefix          = "${var.project_name}-${var.environment}"
  lambda_function_name = local.name_prefix
  lambda_role_name     = "${local.name_prefix}-lambda-role"
  api_gateway_name     = "${var.project_name}-api-${var.environment}"
  dynamodb_table_name  = "${var.project_name}-customers-${var.environment}"

  # Common tags
  common_tags = merge(
    var.additional_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "FIAP"
      CreatedAt   = timestamp()
    }
  )
}

