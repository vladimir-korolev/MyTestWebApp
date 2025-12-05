import os
import json
import boto3
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import time

def get_secret(secret_name, region_name):
    """
    Retrieve secret from AWS Secrets Manager
    """
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(get_secret_value_response['SecretString'])
        return secret
    except Exception as e:
        print(f"Error retrieving secret: {str(e)}")
        raise e

def handler(event, context):
    """
    Lambda function to initialize PostgreSQL database
    Creates database 'app_db' and 'objects' table if they don't exist
    Retrieves database credentials from AWS Secrets Manager
    """
    
    secret_name = os.environ['DB_SECRET_NAME']
    region_name = os.environ.get('AWS_REGION', 'us-east-1')
    db_name = os.environ.get('DB_NAME', 'app_db')
    
    print(f"Retrieving database credentials from Secrets Manager: {secret_name}")
    
    # Get credentials from Secrets Manager
    secret = get_secret(secret_name, region_name)
    
    db_host = secret.get('host') or secret.get('hostname')
    db_port = secret.get('port', 5432)
    db_user = secret.get('username') or secret.get('user')
    db_password = secret.get('password')
    
    if not all([db_host, db_user, db_password]):
        raise ValueError("Missing required database credentials in secret")
    
    print(f"Connecting to database at {db_host}:{db_port}")
    
    # Wait for database to be ready
    max_retries = 30
    for i in range(max_retries):
        try:
            # Connect to default postgres database
            conn = psycopg2.connect(
                host=db_host,
                port=db_port,
                user=db_user,
                password=db_password,
                database='postgres',
                connect_timeout=10
            )
            print("Successfully connected to database")
            break
        except Exception as e:
            if i < max_retries - 1:
                print(f"Waiting for database... ({i+1}/{max_retries}): {str(e)}")
                time.sleep(2)
            else:
                raise Exception(f"Failed to connect to database after {max_retries} attempts: {str(e)}")
    
    try:
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        # Check if database exists
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
        exists = cursor.fetchone()
        
        if not exists:
            print(f"Creating database {db_name}...")
            cursor.execute(f"CREATE DATABASE {db_name}")
            print(f"Database {db_name} created successfully")
        else:
            print(f"Database {db_name} already exists")
        
        cursor.close()
        conn.close()
        
        # Connect to the app database
        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password,
            database=db_name
        )
        cursor = conn.cursor()
        
        # Create objects table
        print("Creating objects table...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS objects (
                id VARCHAR(255) PRIMARY KEY,
                value TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
        print("Objects table created successfully")
        
        cursor.close()
        conn.close()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Database initialized successfully',
                'database': db_name,
                'host': db_host
            })
        }
        
    except Exception as e:
        print(f"Error initializing database: {str(e)}")
        raise e
