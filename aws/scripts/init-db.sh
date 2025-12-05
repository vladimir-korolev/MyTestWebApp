#!/bin/bash
set -e

DB_HOST=$1
DB_PORT=$2
DB_USER=$3
DB_PASSWORD=$4

echo "Checking database connection..."

# Wait for database to be ready
for i in {1..30}; do
  if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1" > /dev/null 2>&1; then
    echo "Database is ready"
    break
  fi
  echo "Waiting for database... ($i/30)"
  sleep 2
done

# Create database if it doesn't exist
echo "Creating database app_db if not exists..."
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres <<-EOSQL
  SELECT 'CREATE DATABASE app_db'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'app_db')\gexec
EOSQL

# Create table
echo "Creating objects table..."
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d app_db <<-EOSQL
  CREATE TABLE IF NOT EXISTS objects (
    id VARCHAR(255) PRIMARY KEY,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
EOSQL

echo "Database initialization complete!"
