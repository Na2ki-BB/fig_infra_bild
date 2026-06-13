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
  default     = "form_invoice_generator_db"
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