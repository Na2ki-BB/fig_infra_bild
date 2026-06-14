locals {
  amplify_branch_url = "https://${var.amplify_branch_name}.${aws_amplify_app.frontend.default_domain}"

  amplify_cognito_callback_url = "${local.amplify_branch_url}/admin/auth/callback"
  amplify_cognito_logout_url   = "${local.amplify_branch_url}/admin/login"
}

resource "aws_amplify_app" "frontend" {
  name       = var.amplify_app_name
  repository = var.amplify_repository_url
  platform   = var.amplify_platform

  build_spec = <<-YAML
version: 1
applications:
  - appRoot: ${var.amplify_monorepo_app_root}
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - "**/*"
      cache:
        paths:
          - node_modules/**/*
YAML

  environment_variables = {
    AMPLIFY_MONOREPO_APP_ROOT = var.amplify_monorepo_app_root
  }

  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-frontend-amplify-app"
  })
}

resource "aws_amplify_branch" "main" {
  app_id            = aws_amplify_app.frontend.id
  branch_name       = var.amplify_branch_name
  framework         = "React"
  stage             = "DEVELOPMENT"
  enable_auto_build = true

  environment_variables = {
    VITE_API_BASE_URL         = aws_apigatewayv2_api.http.api_endpoint
    VITE_COGNITO_DOMAIN       = "https://${aws_cognito_user_pool_domain.admin.domain}.auth.${var.aws_region}.amazoncognito.com"
    VITE_COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.admin_spa.id
    VITE_COGNITO_REDIRECT_URI = local.amplify_cognito_callback_url
    VITE_COGNITO_LOGOUT_URI   = local.amplify_cognito_logout_url
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-frontend-amplify-branch"
  })
}