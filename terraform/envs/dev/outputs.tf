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