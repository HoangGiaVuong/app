# Quick Start — Run All Services (DB, App, Nginx)

This document explains how to start the three services (PostgreSQL, Node.js app, Nginx load balancer) when deploying across separate VMs, or locally on a single host. The repository already contains helper scripts:

- start-db.sh       — start PostgreSQL container
- start_app.sh      — build & run Node.js app (pass INSTANCE_ID)
- start-nginx.sh    — generate nginx.conf and run Nginx
- config.sh         — shared configuration (update per-VM)
- init.sql          — DB initialization script

Prerequisites
- Docker installed on each VM
- The repository files copied to the appropriate VM
- Ports opened in firewall:
  - DB VM: 5432 (optional; required if app VMs access DB over network)
  - App VMs: 3000 (apps bind to this port)
  - LB VM: 80

1) Configure per-VM settings
- Edit `config.sh` on each VM and set IP/port variables:
  - On DB VM: set DB_HOST to DB VM IP (or localhost)
  - On App VMs: set DB_HOST to DB VM IP
  - On LB VM: set APP1_HOST and APP2_HOST to the app VMs' IPs

Example config.sh (minimum):
```bash
DB_HOST="192.168.1.10"     # DB VM IP
DB_PORT="5432"
DB_USER="user"
DB_PASSWORD="password"
DB_NAME="laptop_store"

APP_PORT="3000"
APP1_HOST="192.168.1.11"   # App VM1 IP (LB config)
APP2_HOST="192.168.1.12"   # App VM2 IP (LB config)
```

2) Make scripts executable
```bash
chmod +x start-db.sh start_app.sh start-nginx.sh config.sh
```

3) Start the database (on DB VM)
```bash
# on DB VM
./start-db.sh
# wait ~10s for initialization; check:
docker ps
docker logs laptop_db
# optional: connect to DB
docker exec -it laptop_db psql -U user -d laptop_store
```

4) Start application instances (on each App VM)
- Copy app files (Dockerfile, package.json, server.js, init.sql not required on app VMs) and `config.sh`.
- On App VM1:
```bash
# on App VM1
./start_app.sh APP_A
```
- On App VM2:
```bash
# on App VM2
./start_app.sh APP_B
```
Notes:
- start_app.sh builds the image locally, sets INSTANCE_ID and DB_* env vars when running.
- Ensure the app VM can reach DB VM on DB_HOST:DB_PORT.

5) Start Nginx load balancer (on LB VM)
- Ensure `config.sh` points APP1_HOST and APP2_HOST to app VMs.
```bash
# on LB VM
./start-nginx.sh
```
- Access application: http://<LB_VM_IP>/products
- Health check: http://<LB_VM_IP>/health

6) Verify and troubleshoot
- List containers:
```bash
docker ps
```
- View logs:
```bash
docker logs laptop_db
docker logs laptop_app_APP_A    # or laptop_app_APP_B
docker logs laptop_web
```
- If DB connection fails, confirm DB_HOST and DB_PORT in `config.sh`, and that DB VM accepts remote connections (postgres config / firewall).
- To reset DB (destroy volume):
```bash
docker stop laptop_db && docker rm laptop_db
docker volume rm db_data
./start-db.sh
```

7) Stop & remove containers (manual)
```bash
docker stop laptop_db laptop_app_APP_A laptop_app_APP_B laptop_web || true
docker rm   laptop_db laptop_app_APP_A laptop_app_APP_B laptop_web || true
```

Repository layout (recommended per-VM distribution)
- DB VM:
  - config.sh, start-db.sh, init.sql
- App VMs:
  - config.sh, Dockerfile, package.json, server.js, start_app.sh
- LB VM:
  - config.sh, start-nginx.sh

If anything fails, collect `docker ps` and the relevant `docker logs` output and share for diagnosis.