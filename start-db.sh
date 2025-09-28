#!/bin/bash
source ./config.sh

echo "Cleaning up existing database container..."
docker stop laptop_db || true
docker rm laptop_db || true

echo "Starting PostgreSQL container..."
docker run -d \
    --name laptop_db \
    -p ${DB_PORT}:5432 \
    -e POSTGRES_USER=${DB_USER} \
    -e POSTGRES_PASSWORD=${DB_PASSWORD} \
    -e POSTGRES_DB=${DB_NAME} \
    -v "$(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql" \
    -v db_data:/var/lib/postgresql/data \
    postgres:14-alpine

echo "Database is running on ${DB_HOST}:${DB_PORT}"