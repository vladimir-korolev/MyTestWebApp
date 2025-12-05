# Data source to get existing RDS instance by ARN
data "aws_db_instance" "existing" {
  db_instance_identifier = element(split(":", var.rds_instance_arn), 6)
}

# IAM Role for Lambda
resource "aws_iam_role" "db_init_lambda" {
  name = "${var.project_name}-db-init-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.db_init_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_rds" {
  role = aws_iam_role.db_init_lambda.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances"
        ]
        Resource = var.rds_instance_arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.db_secret_arn
      }
    ]
  })
}

# Lambda Layer for psycopg2 (PostgreSQL driver)
resource "aws_lambda_layer_version" "psycopg2" {
  filename            = data.archive_file.psycopg2_layer.output_path
  layer_name          = "${var.project_name}-psycopg2"
  compatible_runtimes = ["python3.11"]
  source_code_hash    = data.archive_file.psycopg2_layer.output_base64sha256
}

# Attach layer to Lambda
resource "aws_lambda_function" "db_init_with_layer" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-db-init"
  role          = aws_iam_role.db_init_lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 300
  layers        = [aws_lambda_layer_version.psycopg2.arn]

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name
      AWS_REGION     = var.aws_region
      DB_NAME        = "app_db"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy.lambda_rds
  ]
}

# Create Lambda deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/.terraform/lambda_db_init.zip"

  source {
    content  = file("${path.module}/../lambda/db-init/index.py")
    filename = "index.py"
  }
}

# Create psycopg2 layer package
data "archive_file" "psycopg2_layer" {
  type        = "zip"
  output_path = "${path.module}/.terraform/psycopg2_layer.zip"
  source_dir  = "${path.module}/../lambda/layers/psycopg2"
}

# Invoke Lambda to initialize database
resource "aws_lambda_invocation" "db_init" {
  function_name = aws_lambda_function.db_init_with_layer.function_name

  input = jsonencode({
    action = "initialize"
  })

  depends_on = [aws_lambda_function.db_init_with_layer]

  lifecycle {
    replace_triggered_by = [
      aws_lambda_function.db_init_with_layer
    ]
  }
}
