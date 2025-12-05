#!/bin/bash
# Script to create Secrets Manager secret for RDS credentials

set -e

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <secret-name> <db-host> <db-port> <db-username> <db-password>"
    echo "Example: $0 multitier-app/rds/credentials mydb.rds.amazonaws.com 5432 postgres mypassword"
    exit 1
fi

SECRET_NAME=$1
DB_HOST=$2
DB_PORT=$3
DB_USERNAME=$4
DB_PASSWORD=$5

echo "Creating Secrets Manager secret: $SECRET_NAME"

aws secretsmanager create-secret \
    --name "$SECRET_NAME" \
    --description "RDS database credentials for multitier application" \
    --secret-string "{\"host\":\"$DB_HOST\",\"port\":$DB_PORT,\"username\":\"$DB_USERNAME\",\"password\":\"$DB_PASSWORD\"}"

echo "Secret created successfully!"
echo "ARN: $(aws secretsmanager describe-secret --secret-id $SECRET_NAME --query 'ARN' --output text)"
