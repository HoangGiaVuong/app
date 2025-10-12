#!/bin/bash
source ./config.sh

# Get instance ID from command line argument
INSTANCE_ID=$1
if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: ./start-app.sh <INSTANCE_ID>"
    exit 1
fi

echo "Cleaning up existing application container..."
docker stop laptop_app_${INSTANCE_ID} || true
docker rm laptop_app_${INSTANCE_ID} || true

echo "Building Node.js application image..."
docker build -t laptop-app \
    --build-arg DB_HOST=${DB_HOST} \
    --build-arg DB_PORT=${DB_PORT} \
    --build-arg DB_USER=${DB_USER} \
    --build-arg DB_PASSWORD=${DB_PASSWORD} \
    --build-arg DB_NAME=${DB_NAME} \
    .

echo "Starting Node.js application instance ${INSTANCE_ID}..."
docker run -d \
    --name laptop_app_${INSTANCE_ID} \
    -p ${APP_PORT}:3000 \
    -e INSTANCE_ID=${INSTANCE_ID} \
    -e DB_HOST=${DB_HOST} \
    -e DB_PORT=${DB_PORT} \
    -e DB_USER=${DB_USER} \
    -e DB_PASSWORD=${DB_PASSWORD} \
    -e DB_NAME=${DB_NAME} \
    laptop-app

echo "Application ${INSTANCE_ID} is running on port ${APP_PORT}"