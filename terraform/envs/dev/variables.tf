variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
  default     = "ap-northeast-1"
}

variable "project_short" {
  description = "Short project code used in AWS resource names."
  type        = string
  default     = "fig"
}

variable "project_name" {
  description = "Human-readable project name used in tags."
  type        = string
  default     = "form-invoice-generator"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the dev VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for the private subnet in ap-northeast-1a."
  type        = string
  default     = "10.20.10.0/24"
}

variable "private_subnet_c_cidr" {
  description = "CIDR block for the private subnet in ap-northeast-1c."
  type        = string
  default     = "10.20.11.0/24"
}

variable "private_subnet_a_az" {
  description = "Availability zone for the private subnet A."
  type        = string
  default     = "ap-northeast-1a"
}

variable "private_subnet_c_az" {
  description = "Availability zone for the private subnet C."
  type        = string
  default     = "ap-northeast-1c"
}

variable "db_name" {
  description = "Initial database name for PostgreSQL."
  type        = string
  default     = "form_invoice_generator"
}

variable "db_master_username" {
  description = "Master username for PostgreSQL."
  type        = string
  default     = "fig_master"
}

variable "db_instance_class" {
  description = "Instance class for the PostgreSQL RDS instance."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for PostgreSQL in GiB."
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Storage type for PostgreSQL."
  type        = string
  default     = "gp3"
}

variable "db_backup_retention_period" {
  description = "Backup retention period for PostgreSQL in days."
  type        = number
  default     = 7
}

variable "db_deletion_protection" {
  description = "Whether deletion protection is enabled for PostgreSQL."
  type        = bool
  default     = true
}

variable "app_database_url_secret_name" {
  description = "Name of the Secrets Manager secret for the application DATABASE_URL."
  type        = string
  default     = "fig-dev/database-url"
}

variable "api_ecr_repository_name" {
  description = "Name of the ECR repository for the API image."
  type        = string
  default     = "fig-dev-api"
}

variable "migration_ecr_repository_name" {
  description = "Name of the ECR repository for the migration image."
  type        = string
  default     = "fig-dev-migrations"
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for ECR repositories."
  type        = string
  default     = "MUTABLE"
}

variable "api_log_group_name" {
  description = "CloudWatch log group name for the API ECS task."
  type        = string
  default     = "/ecs/fig-dev-api"
}

variable "migration_log_group_name" {
  description = "CloudWatch log group name for the migration ECS task."
  type        = string
  default     = "/ecs/fig-dev-migrations"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days."
  type        = number
  default     = 7
}

variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution IAM role."
  type        = string
  default     = "fig-dev-ecs-task-execution-role"
}

variable "api_task_role_name" {
  description = "Name of the API ECS task IAM role."
  type        = string
  default     = "fig-dev-ecs-task-role"
}

variable "migration_task_role_name" {
  description = "Name of the migration ECS task IAM role."
  type        = string
  default     = "fig-dev-migration-task-role"
}

variable "alb_name" {
  description = "Name of the internal ALB for the API."
  type        = string
  default     = "fig-dev-api-alb"
}

variable "target_group_name" {
  description = "Name of the ALB target group for the API."
  type        = string
  default     = "fig-dev-api-tg"
}

variable "alb_listener_port" {
  description = "Port for the internal ALB HTTP listener."
  type        = number
  default     = 80
}

variable "api_container_port" {
  description = "Container port for the API service."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path for the API target group."
  type        = string
  default     = "/health"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
  default     = "fig-dev-cluster"
}

variable "api_task_family" {
  description = "Family name for the API ECS task definition."
  type        = string
  default     = "fig-dev-api"
}

variable "migration_task_family" {
  description = "Family name for the migration ECS task definition."
  type        = string
  default     = "fig-dev-migrations"
}

variable "api_container_name" {
  description = "Container name for the API task."
  type        = string
  default     = "api"
}

variable "migration_container_name" {
  description = "Container name for the migration task."
  type        = string
  default     = "migrations"
}

variable "api_image_tag" {
  description = "Image tag for the API container."
  type        = string
  default     = "latest"
}

variable "migration_image_tag" {
  description = "Image tag for the migration container."
  type        = string
  default     = "latest"
}

variable "api_cpu" {
  description = "CPU units for the API ECS task."
  type        = number
  default     = 256
}

variable "api_memory" {
  description = "Memory for the API ECS task in MiB."
  type        = number
  default     = 512
}

variable "migration_cpu" {
  description = "CPU units for the migration ECS task."
  type        = number
  default     = 256
}

variable "migration_memory" {
  description = "Memory for the migration ECS task in MiB."
  type        = number
  default     = 512
}

variable "app_auth_mode" {
  description = "Authentication mode for the API application."
  type        = string
  default     = "trusted_gateway"
}

variable "app_cors_allowed_origin" {
  description = "Allowed CORS origin for the API application."
  type        = string
  default     = "https://example.invalid"
}

variable "api_service_name" {
  description = "Name of the ECS service for the API."
  type        = string
  default     = "fig-dev-api-service"
}

variable "api_desired_count" {
  description = "Desired number of running API ECS tasks."
  type        = number
  default     = 1
}

variable "api_assign_public_ip" {
  description = "Whether to assign a public IP to API ECS tasks."
  type        = bool
  default     = false
}

variable "cognito_user_pool_name" {
  description = "Name of the Cognito User Pool for admin users."
  type        = string
  default     = "fig-dev-admin-users"
}

variable "cognito_app_client_name" {
  description = "Name of the Cognito App Client for the admin SPA."
  type        = string
  default     = "fig-dev-admin-spa"
}

variable "cognito_domain_prefix" {
  description = "Domain prefix for the Cognito hosted login domain. Must be unique in the region."
  type        = string
  default     = "fig-dev-admin-auth"
}

variable "cognito_callback_url" {
  description = "OAuth callback URL for the admin SPA. Replace with the Amplify URL later."
  type        = string
  default     = "https://example.invalid/admin/auth/callback"
}

variable "cognito_logout_url" {
  description = "OAuth logout URL for the admin SPA. Replace with the Amplify URL later."
  type        = string
  default     = "https://example.invalid/admin/login"
}

variable "cognito_oauth_flows" {
  description = "OAuth flows enabled for the Cognito App Client."
  type        = list(string)
  default     = ["code"]
}

variable "cognito_oauth_scopes" {
  description = "OAuth scopes enabled for the Cognito App Client."
  type        = list(string)
  default     = ["openid", "email", "profile"]
}

variable "cognito_identity_providers" {
  description = "Identity providers enabled for the Cognito App Client."
  type        = list(string)
  default     = ["COGNITO"]
}

variable "http_api_name" {
  description = "Name of the API Gateway HTTP API."
  type        = string
  default     = "fig-dev-api"
}

variable "api_stage_name" {
  description = "Name of the API Gateway stage."
  type        = string
  default     = "$default"
}

variable "api_stage_auto_deploy" {
  description = "Whether API Gateway stage auto deploy is enabled."
  type        = bool
  default     = true
}

variable "api_vpc_link_name" {
  description = "Name of the API Gateway VPC Link."
  type        = string
  default     = "fig-dev-api-vpc-link"
}

variable "api_payload_format_version" {
  description = "Payload format version for the API Gateway HTTP proxy integration."
  type        = string
  default     = "1.0"
}

variable "api_cors_allowed_origins" {
  description = "Allowed CORS origins for the HTTP API. Replace with the Amplify URL later."
  type        = list(string)
  default     = ["https://example.invalid"]
}

variable "api_cors_allowed_methods" {
  description = "Allowed CORS methods for the HTTP API."
  type        = list(string)
  default     = ["GET", "POST", "PUT", "OPTIONS"]
}

variable "api_cors_allowed_headers" {
  description = "Allowed CORS headers for the HTTP API."
  type        = list(string)
  default     = ["Content-Type", "Authorization"]
}

variable "api_cors_expose_headers" {
  description = "CORS response headers exposed to the browser."
  type        = list(string)
  default     = ["Content-Disposition"]
}

variable "api_cors_max_age" {
  description = "CORS preflight cache duration in seconds."
  type        = number
  default     = 300
}

variable "jwt_authorizer_name" {
  description = "Name of the API Gateway JWT authorizer for admin routes."
  type        = string
  default     = "fig-dev-cognito-admin-authorizer"
}

variable "amplify_app_name" {
  description = "Name of the Amplify app for the frontend."
  type        = string
  default     = "fig-dev-frontend"
}

variable "amplify_repository_url" {
  description = "GitHub repository URL for the frontend application."
  type        = string
  default     = "https://github.com/Na2ki-BB/form_invoice_generator.git"
}

variable "amplify_branch_name" {
  description = "Git branch name deployed by Amplify."
  type        = string
  default     = "main"
}

variable "amplify_monorepo_app_root" {
  description = "Frontend app root path inside the application repository."
  type        = string
  default     = "frontend"
}

variable "amplify_platform" {
  description = "Amplify app platform."
  type        = string
  default     = "WEB"
}
