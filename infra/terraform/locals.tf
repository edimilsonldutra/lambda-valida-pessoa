# Local values for resource naming and tagging
locals {
  # Resource names
  name_prefix          = "${var.project_name}-${var.environment}"
  lambda_function_name = local.name_prefix
  lambda_role_name     = "${local.name_prefix}-lambda-role"
  api_gateway_name     = "${var.project_name}-api-${var.environment}"
  dynamodb_table_name  = "${var.project_name}-customers-${var.environment}"

  # New Relic monitoring flag (non-sensitive for use in count)
  # This checks if monitoring is enabled AND credentials are provided
  enable_newrelic = var.enable_new_relic_monitoring && try(length(var.new_relic_api_key) > 0, false)

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

