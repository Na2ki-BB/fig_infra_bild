output "name_prefix" {
  description = "Prefix to use for dev resource names."
  value       = local.name_prefix
}

output "common_tags" {
  description = "Common tags applied to AWS resources."
  value       = local.common_tags
}