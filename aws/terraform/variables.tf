variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "multitier-app"
}

# Existing Autoscaling Group Names
variable "backend_dev_asg_name" {
  description = "Existing backend dev autoscaling group name"
  type        = string
}

variable "backend_prod_asg_name" {
  description = "Existing backend prod autoscaling group name"
  type        = string
}

variable "frontend_dev_asg_name" {
  description = "Existing frontend dev autoscaling group name"
  type        = string
}

variable "frontend_prod_asg_name" {
  description = "Existing frontend prod autoscaling group name"
  type        = string
}

# Existing Target Group Names
variable "backend_dev_target_group_name" {
  description = "Existing backend dev target group name"
  type        = string
}

variable "backend_prod_target_group_name" {
  description = "Existing backend prod target group name"
  type        = string
}

variable "frontend_dev_target_group_name" {
  description = "Existing frontend dev target group name"
  type        = string
}

variable "frontend_prod_target_group_name" {
  description = "Existing frontend prod target group name"
  type        = string
}

# RDS Configuration
variable "rds_instance_arn" {
  description = "ARN of existing RDS instance"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  type        = string
}


