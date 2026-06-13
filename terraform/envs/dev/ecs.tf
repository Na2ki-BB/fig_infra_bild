resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-cluster"
  })
}

resource "aws_ecs_task_definition" "migrations" {
  family                   = var.migration_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.migration_cpu
  memory                   = var.migration_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.migration_task.arn

  container_definitions = jsonencode([
    {
      name      = var.migration_container_name
      image     = "${aws_ecr_repository.migrations.repository_url}:${var.migration_image_tag}"
      essential = true

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.app_database_url.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.migrations.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "migrations"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-migrations-task-definition"
  })
}

resource "aws_ecs_task_definition" "api" {
  family                   = var.api_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.api_task.arn

  container_definitions = jsonencode([
    {
      name      = var.api_container_name
      image     = "${aws_ecr_repository.api.repository_url}:${var.api_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.api_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "APP_AUTH_MODE"
          value = var.app_auth_mode
        },
        {
          name  = "APP_CORS_ALLOWED_ORIGIN"
          value = var.app_cors_allowed_origin
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.app_database_url.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-task-definition"
  })
}