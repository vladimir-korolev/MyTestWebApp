#!/bin/bash
# Script to build psycopg2 Lambda layer

set -e

echo "Building psycopg2 Lambda layer..."

# Create directory structure
mkdir -p python/lib/python3.11/site-packages

# Install psycopg2-binary into the layer directory
pip install psycopg2-binary==2.9.9 -t python/lib/python3.11/site-packages/

echo "Layer built successfully in python/ directory"
echo "Terraform will zip this directory automatically"
