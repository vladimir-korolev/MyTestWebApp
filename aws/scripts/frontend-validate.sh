#!/bin/bash
set -e

echo "Validating frontend service..."
sleep 10

for i in {1..30}; do
  if curl -f http://localhost:3000/ > /dev/null 2>&1; then
    echo "Frontend service is healthy"
    exit 0
  fi
  echo "Waiting for frontend service... ($i/30)"
  sleep 2
done

echo "Frontend service failed to start"
exit 1
