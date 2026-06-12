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