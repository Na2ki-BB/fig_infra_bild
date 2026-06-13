resource "aws_cloudwatch_log_group" "api" {
  name              = var.api_log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-log-group"
  })
}

resource "aws_cloudwatch_log_group" "migrations" {
  name              = var.migration_log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-migrations-log-group"
  })
}