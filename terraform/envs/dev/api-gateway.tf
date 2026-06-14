resource "aws_apigatewayv2_api" "http" {
  name          = var.http_api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = [local.amplify_branch_url]
    allow_methods  = var.api_cors_allowed_methods
    allow_headers  = var.api_cors_allowed_headers
    expose_headers = var.api_cors_expose_headers
    max_age        = var.api_cors_max_age
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-http-api"
  })
}

resource "aws_apigatewayv2_vpc_link" "api" {
  name = var.api_vpc_link_name

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]

  security_group_ids = [
    aws_security_group.apigw_vpc_link.id,
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-vpc-link"
  })
}

resource "aws_apigatewayv2_integration" "alb" {
  api_id = aws_apigatewayv2_api.http.id

  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.api.id

  integration_uri        = aws_lb_listener.http.arn
  payload_format_version = var.api_payload_format_version
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_route" "public_forms_get" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /public/forms/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_route" "public_forms_post" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /public/forms/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_route" "submissions_post" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /submissions"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_route" "admin_options" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "OPTIONS /admin/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_authorizer" "admin" {
  api_id          = aws_apigatewayv2_api.http.id
  name            = var.jwt_authorizer_name
  authorizer_type = "JWT"

  identity_sources = [
    "$request.header.Authorization",
  ]

  jwt_configuration {
    issuer = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.admin.id}"

    audience = [
      aws_cognito_user_pool_client.admin_spa.id,
    ]
  }
}

resource "aws_apigatewayv2_route" "admin_any" {
  api_id             = aws_apigatewayv2_api.http.id
  route_key          = "ANY /admin/{proxy+}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.admin.id
  target             = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = var.api_stage_name
  auto_deploy = var.api_stage_auto_deploy

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-default-stage"
  })
}
