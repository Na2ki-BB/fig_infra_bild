variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
  default     = "ap-northeast-1"
}

variable "project" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "fig-infra-bild"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}
