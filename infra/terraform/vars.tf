# AWS Region
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^(us|eu|ap|sa|ca|me|af)-(north|south|east|west|central|northeast|southeast)-[1-9]$", var.aws_region))
    error_message = "Must be a valid AWS region name."
  }
}

# Environment
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Project Name
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "valida-pessoa"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# JWT Configuration
variable "jwt_secret" {
  description = "Secret key for JWT generation (minimum 32 characters)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "JWT secret must be at least 32 characters long."
  }
}

variable "jwt_expiration_ms" {
  description = "JWT token expiration time in milliseconds"
  type        = number
  default     = 3600000 # 1 hour

  validation {
    condition     = var.jwt_expiration_ms > 0 && var.jwt_expiration_ms <= 86400000
    error_message = "JWT expiration must be between 1ms and 24 hours."
  }
}

# Lambda Configuration
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.lambda_timeout >= 3 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 3 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory must be between 128 and 10240 MB."
  }
}

variable "lambda_jar_path" {
  description = "Path to Lambda JAR file relative to terraform directory"
  type        = string
  default     = "../../LambdaValidaPessoa/target/HelloWorld-1.0.jar"
}

# DynamoDB Configuration
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.dynamodb_billing_mode)
    error_message = "Billing mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = false
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period."
  }
}

# API Gateway Configuration
variable "api_throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 5000
}

variable "api_throttle_rate_limit" {
  description = "API Gateway throttle rate limit (requests per second)"
  type        = number
  default     = 10000
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Additional Lambda Configuration
# ============================================================================

variable "lambda_reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the Lambda function (-1 for unreserved)"
  type        = number
  default     = -1

  validation {
    condition     = var.lambda_reserved_concurrent_executions >= -1
    error_message = "Reserved concurrent executions must be -1 (unreserved) or a positive number."
  }
}

# ============================================================================
# Additional DynamoDB Configuration
# ============================================================================

variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5

  validation {
    condition     = var.dynamodb_read_capacity >= 1
    error_message = "Read capacity must be at least 1."
  }
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5

  validation {
    condition     = var.dynamodb_write_capacity >= 1
    error_message = "Write capacity must be at least 1."
  }
}

variable "enable_dynamodb_streams" {
  description = "Enable DynamoDB Streams for change data capture"
  type        = bool
  default     = false
}

variable "dynamodb_stream_view_type" {
  description = "DynamoDB stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.dynamodb_stream_view_type)
    error_message = "Stream view type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

# ============================================================================
# Additional CloudWatch Configuration
# ============================================================================

variable "enable_lambda_insights" {
  description = "Enable Lambda Insights for enhanced monitoring"
  type        = bool
  default     = false
}

# ============================================================================
# Additional API Gateway Configuration
# ============================================================================

variable "enable_api_cache" {
  description = "Enable API Gateway caching"
  type        = bool
  default     = false
}

variable "api_cache_ttl" {
  description = "API Gateway cache TTL in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.api_cache_ttl >= 0 && var.api_cache_ttl <= 3600
    error_message = "Cache TTL must be between 0 and 3600 seconds."
  }
}

# ============================================================================
# Alarm Configuration
# ============================================================================

variable "enable_alarms" {
  description = "Enable CloudWatch alarms for monitoring"
  type        = bool
  default     = true
}

variable "lambda_error_threshold" {
  description = "Number of Lambda errors before triggering alarm"
  type        = number
  default     = 5

  validation {
    condition     = var.lambda_error_threshold > 0
    error_message = "Error threshold must be greater than 0."
  }
}

variable "lambda_duration_alarm_threshold_percentage" {
  description = "Percentage of timeout before triggering duration alarm (e.g., 80 for 80%)"
  type        = number
  default     = 80

  validation {
    condition     = var.lambda_duration_alarm_threshold_percentage > 0 && var.lambda_duration_alarm_threshold_percentage <= 100
    error_message = "Duration alarm threshold must be between 0 and 100 percent."
  }
}

variable "alarm_evaluation_periods" {
  description = "Number of periods to evaluate before triggering alarm"
  type        = number
  default     = 2

  validation {
    condition     = var.alarm_evaluation_periods >= 1
    error_message = "Evaluation periods must be at least 1."
  }
}

# ============================================================================
# VPC Configuration
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

# Remove old VPC variables that are now obsolete
# variable "vpc_id" - now created by vpc.tf
# variable "rds_subnet_ids" - now created by vpc.tf
# variable "lambda_security_group_ids" - now created by lambda.tf

# ============================================================================
# Feature Flags
# ============================================================================

variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing for Lambda and API Gateway"
  type        = bool
  default     = false
}

variable "create_sample_data" {
  description = "Create sample customer data in DynamoDB (only for dev environment)"
  type        = bool
  default     = true
}

variable "enable_cors" {
  description = "Enable CORS configuration for API Gateway"
  type        = bool
  default     = true
}

variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing DB credentials"
  type        = string
}

variable "db_schema" {
  description = "Database schema name"
  type        = string
  default     = "public"
}

variable "db_table" {
  description = "Database table name for people/customers"
  type        = string
  default     = "pessoas"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage (GB)"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "valida_pessoa"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "db_backup_retention" {
  description = "Backup retention period (days)"
  type        = number
  default     = 0
}

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on destroy"
  type        = bool
  default     = true
}

variable "db_secret_name" {
  description = "Name of the Secrets Manager secret for DB credentials"
  type        = string
  default     = "valida-pessoa-db-credentials"
}

# ============================================================================
# New Relic Monitoring Configuration
# ============================================================================

variable "new_relic_license_key" {
  description = "New Relic license key for APM monitoring"
  type        = string
  sensitive   = true
  default     = ""
}

variable "new_relic_lambda_layer_arn" {
  description = "ARN of the New Relic Lambda Layer for Java"
  type        = string
  default     = "arn:aws:lambda:us-east-1:451483290750:layer:NewRelicJava21:1"
}

variable "enable_new_relic_monitoring" {
  description = "Enable New Relic APM monitoring"
  type        = bool
  default     = true
}

variable "new_relic_log_level" {
  description = "New Relic agent log level (off, severe, warning, info, fine, finer, finest)"
  type        = string
  default     = "info"

  validation {
    condition     = contains(["off", "severe", "warning", "info", "fine", "finer", "finest"], var.new_relic_log_level)
    error_message = "New Relic log level must be one of: off, severe, warning, info, fine, finer, finest."
  }
}
