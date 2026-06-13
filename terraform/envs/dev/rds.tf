resource "aws_db_subnet_group" "postgres" {
  name = "${local.name_prefix}-rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-subnet-group"
  })
}

resource "aws_db_instance" "postgres" {
  identifier = "${local.name_prefix}-rds"

  engine         = "postgres"
  db_name        = var.db_name
  username       = var.db_master_username
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = var.db_storage_type

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible         = false
  multi_az                    = false
  backup_retention_period     = var.db_backup_retention_period
  deletion_protection         = var.db_deletion_protection
  manage_master_user_password = true

  skip_final_snapshot = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds"
  })
}

resource "aws_secretsmanager_secret" "app_database_url" {
  name        = var.app_database_url_secret_name
  description = "DATABASE_URL for the application API."

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-database-url"
  })
}