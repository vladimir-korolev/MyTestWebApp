#!/bin/bash
set -e

echo "Starting backend service..."
docker run -d \
  --name backend \
  --restart unless-stopped \
  -p 8080:8080 \
  -e DB_HOST=$DB_HOST \
  -e DB_PORT=$DB_PORT \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  -e DB_NAME=$DB_NAME \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/backend:latest

echo "Backend service started"
