resource "aws_cognito_user_pool" "admin" {
  name = var.cognito_user_pool_name

  username_attributes = ["email"]

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-admin-user-pool"
  })
}

resource "aws_cognito_user_pool_client" "admin_spa" {
  name         = var.cognito_app_client_name
  user_pool_id = aws_cognito_user_pool.admin.id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = var.cognito_oauth_flows
  allowed_oauth_scopes                 = var.cognito_oauth_scopes
  supported_identity_providers         = var.cognito_identity_providers

  callback_urls = [
    local.amplify_cognito_callback_url,
  ]

  logout_urls = [
    local.amplify_cognito_logout_url,
  ]

  explicit_auth_flows = [
    "ALLOW_USER_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "admin" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.admin.id
}
