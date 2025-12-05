#!/bin/bash
set -e

echo "Starting frontend service..."
docker run -d \
  --name frontend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e BACKEND_URL=$BACKEND_URL \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/frontend:latest

echo "Frontend service started"
