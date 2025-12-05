# AWS Deployment Guide

## Architecture Overview

- **Existing Autoscaling Groups**: Your EC2 instances (Dev + Prod for frontend and backend)
- **ECR**: Docker image repositories
- **CodePipeline**: CI/CD automation (4 pipelines: frontend/backend × dev/prod)
- **CodeBuild**: Docker image builds
- **CodeDeploy**: Deployments to existing ASGs with load balancer integration
- **GitHub**: Source repository (dev and main branches)

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Existing Autoscaling Groups for:
   - Backend Dev
   - Backend Prod
   - Frontend Dev
   - Frontend Prod
3. Existing Target Groups (for load balancer integration)
4. EC2 instances in ASGs must have:
   - CodeDeploy agent installed
   - Docker installed
   - IAM role with ECR read permissions
5. GitHub repository: git@github.com:vladimir-korolev/MyTestWebApp.git
6. AWS Secrets Manager secret with RDS credentials in JSON format:
   ```json
   {
     "host": "your-rds-endpoint.rds.amazonaws.com",
     "port": 5432,
     "username": "postgres",
     "password": "your-password"
   }
   ```

## Deployment Steps

### 1. Create Secrets Manager Secret

Create a secret with your RDS credentials:

```bash
cd aws/scripts
chmod +x create-db-secret.sh
./create-db-secret.sh \
  "multitier-app/rds/credentials" \
  "your-rds-endpoint.rds.amazonaws.com" \
  "5432" \
  "postgres" \
  "your-password"
```

Or manually in AWS Console:
- Go to Secrets Manager
- Create new secret
- Select "Other type of secret"
- Add key-value pairs: `host`, `port`, `username`, `password`
- Name it (e.g., `multitier-app/rds/credentials`)

### 2. Configure Terraform Variables

```bash
cd aws/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
- ASG names (backend_dev_asg_name, etc.)
- Target group names
- RDS instance ARN
- Secrets Manager secret name and ARN

### 3. Build Lambda Layer

```bash
cd aws/lambda/layers/psycopg2
docker run --rm -v $(pwd):/var/task public.ecr.aws/lambda/python:3.11 \
  pip install psycopg2-binary==2.9.9 -t python/lib/python3.11/site-packages/
cd ../../../terraform
```

### 4. Deploy Pipeline Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

This creates:
- ECR repositories
- CodeBuild projects
- CodeDeploy applications and deployment groups
- CodePipeline pipelines
- S3 bucket for artifacts
- Lambda function for database initialization
- IAM roles

### 5. Activate GitHub Connection

After Terraform creates the infrastructure, you need to manually activate the GitHub connection:

```bash
# Get the connection ARN from Terraform output
terraform output github_connection_arn

# Go to AWS Console > Developer Tools > Connections
# Find the connection and click "Update pending connection"
# Authorize GitHub access
```

### 6. Pipelines Created

Terraform creates 4 pipelines automatically:

**Dev Environment (triggered by dev branch):**
- `multitier-app-backend-dev`: Builds and deploys backend to dev EC2
- `multitier-app-frontend-dev`: Builds and deploys frontend to dev EC2

**Prod Environment (triggered by main branch):**
- `multitier-app-backend-prod`: Builds and deploys backend to prod EC2
- `multitier-app-frontend-prod`: Builds and deploys frontend to prod EC2

### 7. Verify Deployment

```bash
# Get outputs from Terraform
terraform output

# Check pipeline status in AWS Console
# Developer Tools > CodePipeline

# Test your load balancer endpoints
curl http://<YOUR_FRONTEND_LB>/
curl http://<YOUR_BACKEND_LB>/
```

## Workflow

1. **Development**: Push code to `dev` branch
   - Triggers dev pipelines (backend-dev and frontend-dev)
   - CodeBuild builds Docker images and pushes to ECR
   - CodeDeploy deploys to dev ASG instances
   - Load balancer performs health checks during deployment

2. **Production**: Merge to `main` branch
   - Triggers prod pipelines (backend-prod and frontend-prod)
   - CodeBuild builds Docker images and pushes to ECR
   - CodeDeploy deploys to prod ASG instances
   - Load balancer performs health checks during deployment

## EC2 Instance Requirements

Your ASG launch template or user_data should include:

```bash
# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Install CodeDeploy agent
yum install -y ruby wget
cd /home/ec2-user
wget https://aws-codedeploy-<REGION>.s3.<REGION>.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
```

Ensure IAM role attached to instances has:
- AmazonEC2ContainerRegistryReadOnly
- AmazonEC2RoleforAWSCodeDeploy

## User Data Scripts

The EC2 instances are configured via user_data scripts that:
- Install Docker
- Install CodeDeploy agent
- Set environment variables
- Configure auto-start services

## CodeDeploy Lifecycle

1. **ApplicationStop**: Stop running containers
2. **AfterInstall**: Pull latest Docker images from ECR
3. **ApplicationStart**: Start new containers
4. **ValidateService**: Health check verification

## Environment Variables

Set via user_data or AWS Systems Manager Parameter Store:
- `AWS_REGION`
- `AWS_ACCOUNT_ID`
- `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
- `BACKEND_URL` (for frontend)


## Database Initialization

The Terraform configuration uses an AWS Lambda function to automatically:
1. Check if the RDS instance (by ARN) is available
2. Wait for it to be ready (up to 5 minutes)
3. Create the `app_db` database if it doesn't exist
4. Create the `objects` table with schema:
   - `id` VARCHAR(255) PRIMARY KEY
   - `value` TEXT NOT NULL
   - `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   - `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### Building the Lambda Layer

Before running Terraform, build the psycopg2 Lambda layer:

```bash
cd aws/lambda/layers/psycopg2

# Using Docker (recommended)
docker run --rm -v $(pwd):/var/task public.ecr.aws/lambda/python:3.11 \
  pip install psycopg2-binary==2.9.9 -t python/lib/python3.11/site-packages/

# Or using local Python
chmod +x build-layer.sh
./build-layer.sh
```

The Lambda function runs automatically during `terraform apply` and initializes the database.

### Manual Database Initialization

If you prefer to initialize manually:

```bash
# Using the provided script
cd aws/scripts
chmod +x init-db.sh
./init-db.sh <DB_HOST> <DB_PORT> <DB_USER> <DB_PASSWORD>

# Or using psql directly
PGPASSWORD='your_password' psql -h your-rds-endpoint -U postgres -d postgres -c "CREATE DATABASE app_db"
PGPASSWORD='your_password' psql -h your-rds-endpoint -U postgres -d app_db -c "CREATE TABLE objects (id VARCHAR(255) PRIMARY KEY, value TEXT NOT NULL)"
```
