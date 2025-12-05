#!/bin/bash
set -e

echo "Stopping frontend service..."
docker stop frontend || true
docker rm frontend || true
