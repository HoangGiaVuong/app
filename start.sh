#!/bin/bash

# Stop and remove existing containers
echo "Cleaning up existing containers..."
docker stop laptop_db laptop_app_1 laptop_app_2 laptop_web || true
docker rm laptop_db laptop_app_1 laptop_app_2 laptop_web || true

# Create Docker network if it doesn't exist
echo "Creating Docker network..."
docker network create laptop_network 2>/dev/null || true

# Start PostgreSQL container
echo "Starting PostgreSQL container..."
docker run -d \
    --name laptop_db \
    --network laptop_network \
    -e POSTGRES_USER=user \
    -e POSTGRES_PASSWORD=password \
    -e POSTGRES_DB=laptop_store \
    -v "$(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql" \
    -v db_data:/var/lib/postgresql/data \
    postgres:14-alpine

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Build Node.js application image
echo "Building Node.js application image..."
docker build -t laptop-app .

# Start two Node.js application instances
echo "Starting Node.js application instances..."
docker run -d \
    --name laptop_app_1 \
    --network laptop_network \
    -e INSTANCE_ID=APP_A \
    laptop-app

docker run -d \
    --name laptop_app_2 \
    --network laptop_network \
    -e INSTANCE_ID=APP_B \
    laptop-app

# Start Nginx container
echo "Starting Nginx container..."
docker run -d \
    --name laptop_web \
    --network laptop_network \
    -p 80:80 \
    -v "$(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf:ro" \
    nginx:alpine

# Show running containers
echo -e "\nRunning containers:"
docker ps

echo -e "\nApplication is running!"
echo "Access the application at: http://localhost/products"
echo "Health check at: http://localhost/health"