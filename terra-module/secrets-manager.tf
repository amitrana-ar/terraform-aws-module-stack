resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.env}-${var.rds_name}-secret"
  description = "RDS password for ${var.env}-${var.rds_name}"
  tags = {
    Name = "${var.env}-${var.rds_name}-secret"
    Environment = var.env
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.rds_db_username
    password = var.rds_db_password
  })
}