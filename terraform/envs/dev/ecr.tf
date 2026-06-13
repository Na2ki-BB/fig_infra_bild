resource "aws_ecr_repository" "api" {
  name                 = var.api_ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-ecr-repo"
  })
}

resource "aws_ecr_repository" "migrations" {
  name                 = var.migration_ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-migrations-ecr-repo"
  })
}