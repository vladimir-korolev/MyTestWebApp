# ECR Outputs
output "ecr_frontend_repository_url" {
  description = "ECR frontend repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_repository_url" {
  description = "ECR backend repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

# CodeDeploy Outputs
output "codedeploy_backend_app" {
  description = "CodeDeploy backend application name"
  value       = aws_codedeploy_app.backend.name
}

output "codedeploy_frontend_app" {
  description = "CodeDeploy frontend application name"
  value       = aws_codedeploy_app.frontend.name
}

# Pipeline Outputs
output "github_connection_arn" {
  description = "GitHub connection ARN (needs manual activation)"
  value       = aws_codestarconnections_connection.github.arn
}

output "pipeline_backend_dev" {
  description = "Backend Dev pipeline name"
  value       = aws_codepipeline.backend_dev.name
}

output "pipeline_backend_prod" {
  description = "Backend Prod pipeline name"
  value       = aws_codepipeline.backend_prod.name
}

output "pipeline_frontend_dev" {
  description = "Frontend Dev pipeline name"
  value       = aws_codepipeline.frontend_dev.name
}

output "pipeline_frontend_prod" {
  description = "Frontend Prod pipeline name"
  value       = aws_codepipeline.frontend_prod.name
}


# Database Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = data.aws_db_instance.existing.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = data.aws_db_instance.existing.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = data.aws_db_instance.existing.port
}

output "database_name" {
  description = "Initialized database name"
  value       = "app_db"
}

output "db_secret_name" {
  description = "Secrets Manager secret name for database credentials"
  value       = var.db_secret_name
}
