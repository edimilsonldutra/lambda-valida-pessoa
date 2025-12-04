# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "${local.name_prefix}-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-lambda-sg"
    }
  )
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.lambda_function_name}-logs"
      Type = "CloudWatch-LogGroup"
    }
  )
}

# Lambda Function
resource "aws_lambda_function" "valida_pessoa" {
  function_name    = local.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  filename         = var.lambda_jar_path
  source_code_hash = fileexists(var.lambda_jar_path) ? filebase64sha256(var.lambda_jar_path) : null
  handler          = "lambdavalida.ValidaPessoaFunction::handleRequest"
  runtime          = "java21"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  # VPC Configuration
  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      JWT_SECRET        = var.jwt_secret
      JWT_EXPIRATION_MS = tostring(var.jwt_expiration_ms)
      ENVIRONMENT       = var.environment
      LOG_LEVEL         = var.environment == "prod" ? "INFO" : "DEBUG"
      DB_SECRET_ARN     = aws_secretsmanager_secret.db.arn
      DB_SCHEMA         = var.db_schema
      DB_TABLE          = var.db_table
      # New Relic Configuration
      NEW_RELIC_LICENSE_KEY                  = var.new_relic_license_key
      NEW_RELIC_APP_NAME                     = "${local.lambda_function_name}-${var.environment}"
      NEW_RELIC_LOG_LEVEL                    = var.environment == "prod" ? "info" : "debug"
      NEW_RELIC_DISTRIBUTED_TRACING_ENABLED  = "true"
      NEW_RELIC_EXTENSION_SEND_FUNCTION_LOGS = "true"
      NEW_RELIC_EXTENSION_LOG_LEVEL          = "INFO"
    }
  }

  # Add New Relic Lambda Layer
  layers = [
    var.new_relic_lambda_layer_arn
  ]

  tracing_config {
    mode = var.environment == "prod" ? "Active" : "PassThrough"
  }

  tags = merge(
    local.common_tags,
    {
      Name    = local.lambda_function_name
      Type    = "Lambda"
      Runtime = "java21"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_vpc_execution,
    aws_iam_role_policy_attachment.lambda_secretsmanager,
    aws_db_instance.postgres,
    aws_secretsmanager_secret_version.db_current
  ]

  # Note: Removed redundant ignore_changes for provider-managed attributes
  # (last_modified, qualified_arn, version) as they are automatically ignored
}

# Lambda Function Alias
resource "aws_lambda_alias" "live" {
  name             = "live"
  description      = "Alias pointing to the live version"
  function_name    = aws_lambda_function.valida_pessoa.function_name
  function_version = "$LATEST"
}

# Lambda CloudWatch Alarm - Errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.lambda_function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  alarm_description   = "This metric monitors lambda errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.valida_pessoa.function_name
  }

  tags = local.common_tags
}

# Lambda CloudWatch Alarm - Duration
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.lambda_function_name}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"
  threshold           = var.lambda_timeout * 1000 * (var.lambda_duration_alarm_threshold_percentage / 100)
  alarm_description   = "This metric monitors lambda duration (threshold: ${var.lambda_duration_alarm_threshold_percentage}% of timeout)"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.valida_pessoa.function_name
  }

  tags = local.common_tags
}
