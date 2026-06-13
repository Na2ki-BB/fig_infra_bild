resource "aws_lb_target_group" "api" {
  name        = var.target_group_name
  target_type = "ip"
  protocol    = "HTTP"
  port        = var.api_container_port
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = var.health_check_path
    matcher  = "200"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-target-group"
  })
}

resource "aws_lb" "api" {
  name               = var.alb_name
  internal           = true
  load_balancer_type = "application"

  subnets = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]

  security_groups = [
    aws_security_group.alb.id,
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-alb"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = var.alb_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-alb-http-listener"
  })
}