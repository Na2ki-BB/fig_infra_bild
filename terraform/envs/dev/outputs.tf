output "name_prefix" {
  description = "Prefix to use for dev resource names."
  value       = local.name_prefix
}

output "common_tags" {
  description = "Common tags applied to AWS resources."
  value       = local.common_tags
}

output "vpc_id" {
  description = "ID of the dev VPC."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = aws_route_table.private.id
}

output "apigw_vpc_link_security_group_id" {
  description = "ID of the API Gateway VPC Link security group."
  value       = aws_security_group.apigw_vpc_link.id
}

output "alb_security_group_id" {
  description = "ID of the internal ALB security group."
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS tasks security group."
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group."
  value       = aws_security_group.rds.id
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the interface VPC endpoint security group."
  value       = aws_security_group.vpc_endpoint.id
}

output "interface_vpc_endpoint_ids" {
  description = "IDs of the interface VPC endpoints."
  value = {
    ecr_api        = aws_vpc_endpoint.ecr_api.id
    ecr_dkr        = aws_vpc_endpoint.ecr_dkr.id
    logs           = aws_vpc_endpoint.logs.id
    secretsmanager = aws_vpc_endpoint.secretsmanager.id
  }
}

output "s3_gateway_vpc_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "rds_endpoint" {
  description = "Endpoint address of the PostgreSQL RDS instance."
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Port of the PostgreSQL RDS instance."
  value       = aws_db_instance.postgres.port
}

output "rds_db_name" {
  description = "Database name for the application."
  value       = aws_db_instance.postgres.db_name
}

output "rds_master_username" {
  description = "Master username for PostgreSQL."
  value       = aws_db_instance.postgres.username
}

output "rds_master_user_secret_arn" {
  description = "ARN of the RDS-managed master user secret."
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
  sensitive   = true
}

output "app_database_url_secret_arn" {
  description = "ARN of the application DATABASE_URL secret."
  value       = aws_secretsmanager_secret.app_database_url.arn
  sensitive   = true
}

output "api_ecr_repository_url" {
  description = "Repository URL for the API ECR repository."
  value       = aws_ecr_repository.api.repository_url
}

output "migration_ecr_repository_url" {
  description = "Repository URL for the migration ECR repository."
  value       = aws_ecr_repository.migrations.repository_url
}

output "api_log_group_name" {
  description = "CloudWatch log group name for the API ECS task."
  value       = aws_cloudwatch_log_group.api.name
}

output "migration_log_group_name" {
  description = "CloudWatch log group name for the migration ECS task."
  value       = aws_cloudwatch_log_group.migrations.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "api_task_role_arn" {
  description = "ARN of the API ECS task role."
  value       = aws_iam_role.api_task.arn
}

output "migration_task_role_arn" {
  description = "ARN of the migration ECS task role."
  value       = aws_iam_role.migration_task.arn
}

output "alb_arn" {
  description = "ARN of the internal API ALB."
  value       = aws_lb.api.arn
}

output "alb_dns_name" {
  description = "DNS name of the internal API ALB."
  value       = aws_lb.api.dns_name
}

output "alb_listener_arn" {
  description = "ARN of the internal API ALB HTTP listener."
  value       = aws_lb_listener.http.arn
}

output "api_target_group_arn" {
  description = "ARN of the API ALB target group."
  value       = aws_lb_target_group.api.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "api_task_definition_arn" {
  description = "ARN of the API ECS task definition."
  value       = aws_ecs_task_definition.api.arn
}

output "migration_task_definition_arn" {
  description = "ARN of the migration ECS task definition."
  value       = aws_ecs_task_definition.migrations.arn
}

output "api_service_name" {
  description = "Name of the API ECS service."
  value       = aws_ecs_service.api.name
}

output "api_service_id" {
  description = "ID of the API ECS service."
  value       = aws_ecs_service.api.id
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool for admin users."
  value       = aws_cognito_user_pool.admin.id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool for admin users."
  value       = aws_cognito_user_pool.admin.arn
}

output "cognito_app_client_id" {
  description = "ID of the Cognito App Client for the admin SPA."
  value       = aws_cognito_user_pool_client.admin_spa.id
}

output "cognito_domain" {
  description = "Hosted login domain for the Cognito User Pool."
  value       = "https://${aws_cognito_user_pool_domain.admin.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "cognito_issuer" {
  description = "JWT issuer URL for the Cognito User Pool."
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.admin.id}"
}

output "api_gateway_id" {
  description = "ID of the API Gateway HTTP API."
  value       = aws_apigatewayv2_api.http.id
}

output "api_gateway_endpoint" {
  description = "Endpoint URL of the API Gateway HTTP API."
  value       = aws_apigatewayv2_api.http.api_endpoint
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage."
  value       = aws_apigatewayv2_stage.default.name
}

output "api_gateway_vpc_link_id" {
  description = "ID of the API Gateway VPC Link."
  value       = aws_apigatewayv2_vpc_link.api.id
}

output "api_gateway_integration_id" {
  description = "ID of the API Gateway ALB integration."
  value       = aws_apigatewayv2_integration.alb.id
}

output "api_gateway_authorizer_id" {
  description = "ID of the API Gateway Cognito JWT authorizer."
  value       = aws_apigatewayv2_authorizer.admin.id
}

output "amplify_app_id" {
  description = "ID of the Amplify frontend app."
  value       = aws_amplify_app.frontend.id
}

output "amplify_default_domain" {
  description = "Default domain of the Amplify frontend app."
  value       = aws_amplify_app.frontend.default_domain
}

output "amplify_branch_name" {
  description = "Name of the Amplify frontend branch."
  value       = aws_amplify_branch.main.branch_name
}

output "amplify_branch_url" {
  description = "Default URL of the Amplify frontend branch."
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.frontend.default_domain}"
}
