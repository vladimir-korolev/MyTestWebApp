#!/bin/bash
set -e

echo "Stopping backend service..."
docker stop backend || true
docker rm backend || true
