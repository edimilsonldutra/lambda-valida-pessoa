# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = local.lambda_role_name
      Type = "IAM-Role"
    }
  )
}

# Lambda Assume Role Policy
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Secrets Manager Access Policy for Lambda
data "aws_iam_policy_document" "lambda_secretsmanager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.db.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_secretsmanager_policy" {
  name        = "${local.lambda_role_name}-secretsmanager-policy"
  description = "Policy for Lambda to access Secrets Manager for DB credentials"
  policy      = data.aws_iam_policy_document.lambda_secretsmanager.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.lambda_role_name}-secretsmanager-policy"
      Type = "IAM-Policy"
    }
  )
}

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach AWS managed policy for Lambda VPC execution
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Attach Secrets Manager policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_secretsmanager" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secretsmanager_policy.arn
}
