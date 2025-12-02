# Secrets Manager - DB credentials
resource "aws_secretsmanager_secret" "db" {
  name = var.db_secret_name
  tags = merge(local.common_tags, { Name = var.db_secret_name })
}

resource "aws_secretsmanager_secret_version" "db_current" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username,
    password = var.db_password,
    host     = aws_db_instance.postgres.address,
    port     = 5432,
    dbname   = var.db_name,
    engine   = "postgres"
  })

  depends_on = [aws_db_instance.postgres]
}

