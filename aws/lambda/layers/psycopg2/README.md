# psycopg2 Lambda Layer

This directory contains the psycopg2 library for Lambda.

## Building the Layer

### Option 1: Using Docker (Recommended)
```bash
docker run --rm -v $(pwd):/var/task public.ecr.aws/lambda/python:3.11 \
  pip install psycopg2-binary==2.9.9 -t python/lib/python3.11/site-packages/
```

### Option 2: Using Local Python
```bash
chmod +x build-layer.sh
./build-layer.sh
```

### Option 3: Pre-built Layer
Alternatively, use AWS's public Lambda layer for psycopg2:
- ARN: `arn:aws:lambda:<region>:898466741470:layer:psycopg2-py38:1`

## Directory Structure
After building, you should have:
```
psycopg2/
├── python/
│   └── lib/
│       └── python3.11/
│           └── site-packages/
│               └── psycopg2/
```

Terraform will automatically zip this directory.
