# Laptop Store with Load Balancing

A scalable web application demonstrating load balancing with Node.js, Nginx, and PostgreSQL using Docker containers.

## Architecture Overview

- **Frontend**: Simple HTML/TailwindCSS
- **Backend**: Node.js/Express (2 instances for load balancing)
- **Database**: PostgreSQL
- **Load Balancer**: Nginx
- **Container Orchestration**: Docker Compose

## Prerequisites

- Docker and Docker Compose installed
- Node.js 20.x or higher (for local development)
- Git (optional)

## Getting Started

1. Clone the repository (if using Git):
```bash
git clone <repository-url>
cd laptop-store
```

2. Create and configure the environment file:
```bash
cp .env.example .env
# Edit .env file with your desired configuration
```

3. Make sure all required files are present:
```
.
├── docker-compose.yaml
├── Dockerfile
├── init.sql
├── nginx.conf
├── package.json
├── README.md
└── server.js
```

4. Start the application using Docker Compose:
```bash
docker-compose up --build
```

5. Access the application:
- Open your browser and visit: `http://localhost`
- Refresh the page multiple times to see load balancing in action (notice the Instance ID changes)

## Accessing the Application

### Main Application
1. **Products Page**:
   - Open your web browser
   - Visit: `http://localhost/products`
   - Refresh the page to see load balancing between instances (APP_A and APP_B)

2. **Health Check**:
   - Visit: `http://localhost/health`
   - You'll see a JSON response:
   ```json
   {
       "status": "OK",
       "instance": "APP_A"  // or "APP_B"
   }
   ```

### Monitoring and Debugging

1. **View Application Logs**:
```bash
# View all containers logs
docker-compose logs

# View specific service logs
docker-compose logs app1    # First Node.js instance
docker-compose logs app2    # Second Node.js instance
docker-compose logs web     # Nginx logs
docker-compose logs db      # Database logs

# Follow logs in real-time
docker-compose logs -f
```

2. **Database Access** (Development Only):
```bash
# Connect to PostgreSQL database
docker exec -it laptop_db psql -U user -d laptop_store

# Useful PostgreSQL commands:
# \dt                         - List all tables
# SELECT * FROM laptops;      - View all products
# \q                         - Exit psql
```

## Application Structure

- `docker-compose.yaml`: Defines and configures all services
- `Dockerfile`: Instructions for building the Node.js application container
- `init.sql`: Database initialization script with sample data
- `nginx.conf`: Nginx load balancer configuration
- `server.js`: Main application code
- `package.json`: Node.js dependencies and scripts

## Services

1. **Database (PostgreSQL)**
   - Port: 5432
   - Credentials:
     - User: user
     - Password: password
     - Database: laptop_store

2. **Web Application (Node.js)**
   - Two instances (app1 and app2)
   - Each instance runs on port 3000 internally
   - Load balanced by Nginx

3. **Load Balancer (Nginx)**
   - Port: 80
   - Distributes traffic between app instances
   - Implements round-robin algorithm

## Development

To modify the application:

1. Stop running containers:
```bash
docker-compose down
```

2. Make your changes to the code

3. Rebuild and start the containers:
```bash
docker-compose up --build
```

## Troubleshooting

1. If the application fails to start:
   - Check if ports 80 and 5432 are available
   - Ensure Docker service is running
   - View logs: `docker-compose logs`

2. To reset the database:
```bash
docker-compose down -v
docker-compose up --build
```

## License

[Your License Here]

## Contributing

[Your Contributing Guidelines Here]