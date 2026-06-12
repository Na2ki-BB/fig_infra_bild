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
