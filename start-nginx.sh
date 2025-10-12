#!/bin/bash
source ./config.sh

echo "Creating Nginx configuration..."
cat > nginx.conf <<EOF
upstream laptop_app {
    server ${APP1_HOST}:${APP_PORT};
    server ${APP2_HOST}:${APP_PORT};
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://laptop_app;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

echo "Cleaning up existing Nginx container..."
docker stop laptop_web || true
docker rm laptop_web || true

echo "Starting Nginx container..."
docker run -d \
    --name laptop_web \
    -p 80:80 \
    -v "$(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf:ro" \
    nginx:alpine

echo "Nginx load balancer is running on port 80"