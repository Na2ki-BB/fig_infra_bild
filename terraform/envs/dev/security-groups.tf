resource "aws_security_group" "apigw_vpc_link" {
  name        = "${local.name_prefix}-apigw-vpclink-sg"
  description = "Security group for API Gateway VPC Link."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-apigw-vpclink-sg"
  })
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for internal ALB."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "ecs" {
  name        = "${local.name_prefix}-ecs-sg"
  description = "Security group for ECS tasks."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-sg"
  })
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for RDS PostgreSQL."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
  })
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "${local.name_prefix}-vpce-sg"
  description = "Security group for interface VPC endpoints."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpce-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "apigw_vpc_link_to_alb_http" {
  security_group_id            = aws_security_group.apigw_vpc_link.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "Allow API Gateway VPC Link to reach ALB on HTTP"
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_apigw_vpc_link_http" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.apigw_vpc_link.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "Allow internal ALB to receive HTTP from API Gateway VPC Link"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_api" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  description                  = "Allow internal ALB to reach ECS API tasks."
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb_api" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  description                  = "Allow ECS API tasks to receive traffic from internal ALB."
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_rds_postgres" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.rds.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "Allow ECS tasks to reach RDS PostgreSQL."
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs_postgres" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "Allow RDS PostgreSQL to receive traffic from ECS tasks."
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_vpc_endpoint_https" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.vpc_endpoint.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Allow ECS tasks to reach interface VPC endpoints over HTTPS."
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_from_ecs_https" {
  security_group_id            = aws_security_group.vpc_endpoint.id
  referenced_security_group_id = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Allow interface VPC endpoints to receive HTTPS traffic from ECS tasks."
}