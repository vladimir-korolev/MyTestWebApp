# Multitier Web Application

A three-tier web application with Node.js frontend, Go backend, and PostgreSQL database.

## Architecture

- **Frontend (Web Tier)**: Node.js/Express on port 3000
- **Backend (Application Tier)**: Go/Gorilla Mux on port 8080
- **Database (Data Tier)**: PostgreSQL on port 5432

## API Endpoints

### Frontend & Backend
- `GET /` - Health check endpoint
- `GET /get_object/:id` - Retrieve an object by ID
- `POST /put_object` - Store an object (body: `{"id": "string", "value": "string"}`)

## Running the Application

```bash
docker-compose up --build
```

Access the web interface at: http://localhost:3000

## Testing

Health checks:
```bash
curl http://localhost:3000/
curl http://localhost:8080/
```

Store an object:
```bash
curl -X POST http://localhost:3000/put_object \
  -H "Content-Type: application/json" \
  -d '{"id": "test1", "value": "Hello World"}'
```

Retrieve an object:
```bash
curl http://localhost:3000/get_object/test1
```
