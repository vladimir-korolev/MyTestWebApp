#!/bin/bash
set -e

echo "Validating backend service..."
sleep 10

for i in {1..30}; do
  if curl -f http://localhost:8080/ > /dev/null 2>&1; then
    echo "Backend service is healthy"
    exit 0
  fi
  echo "Waiting for backend service... ($i/30)"
  sleep 2
done

echo "Backend service failed to start"
exit 1
