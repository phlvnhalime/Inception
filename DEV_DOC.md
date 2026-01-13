# Developer Documentation

This document describes how to set up, build, and manage the Inception project from a developer's perspective.

---

## 1. Environment Setup from Scratch

### Prerequisites

Ensure the following are installed on your system:

| Tool | Purpose | Installation |
|------|---------|--------------|
| Docker | Container runtime | [docs.docker.com](https://docs.docker.com/get-docker/) |
| Docker Compose | Container orchestration | Included with Docker Desktop |
| Make | Build automation | `apt install make` (Linux) / `xcode-select --install` (macOS) |
| Git | Version control | `apt install git` (Linux) / `brew install git` (macOS) |

### Clone the Repository
```bash
git clone https://github.com/hpehliva/Inception.git
cd Inception
```

### Configure Host Domain
Add the domain to your hosts file:
```bash
# Linux
sudo sh -c 'echo "127.0.0.1 hpehliva.42.fr" >> /etc/hosts'

# macOS
sudo sh -c 'echo "127.0.0.1 hpehliva.42.fr" >> /etc/hosts'
```

### Create Secrets Directory
```bash
mkdir -p secrets
```

Create the following secret files:
```bash
# Database root password
echo "your_secure_root_password" > secrets/db_root_password.txt

# Database user password
echo "your_secure_db_password" > secrets/db_user_password.txt

# WordPress admin password
echo "your_secure_admin_password" > secrets/admin_password.txt

# WordPress user password
echo "your_secure_user_password" > secrets/user_password.txt
```

### Create Environment File
Create `srcs/.env` with the following variables:
```bash
# Domain
DOMAIN_NAME=hpehliva.42.fr

# Database Configuration
DB_NAME=wordpress
DB_USER=wpuser

# WordPress Admin
WP_ADMIN=admin
WP_ADMIN_EMAIL=admin@example.com

# WordPress User
WP_USER=user
WP_USER_EMAIL=user@example.com
```

### Update Data Paths

Modify paths in `docker-compose.yml` and `Makefile` to match your system:

```bash
# Linux: /home/<your_username>/data/
# macOS: /Users/<your_username>/data/
```

**Files to update:**
- `srcs/docker-compose.yml` (lines 58, 66)
- `Makefile` (lines 5, 6, 21, 22)

---

## 2. Building and Launching

### Using Makefile

The project uses Make for build automation:

```bash
# Build and start all containers
make

# This executes:
# 1. Creates data directories: /home/<user>/data/wordpress and /home/<user>/data/mariadb
# 2. Runs: docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build
```

### Using Docker Compose Directly

```bash
# Build and start
docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

# Build without cache
docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env build --no-cache

# Start without rebuild
docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d
```

### Build Individual Services
```bash
# Build only nginx
docker compose -f ./srcs/docker-compose.yml build nginx

# Build only wordpress
docker compose -f ./srcs/docker-compose.yml build wordpress

# Build only mariadb
docker compose -f ./srcs/docker-compose.yml build mariadb
```

---

## 3. Container and Volume Management

### Makefile Commands Reference

| Command | Description | Docker Equivalent |
|---------|-------------|-------------------|
| `make` / `make all` | Build and start all containers | `docker compose up -d --build` |
| `make down` | Stop all containers | `docker compose down` |
| `make re` | Restart (down + all) | `docker compose down && docker compose up -d --build` |
| `make clean` | Stop + prune system | `docker compose down && docker system prune -a` |
| `make fclean` | Full clean (removes all data) | Removes volumes, data directories, networks |

### Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a specific container
docker stop nginx

# Start a specific container
docker start nginx

# Restart a specific container
docker restart nginx

# View container logs
docker logs nginx
docker logs -f nginx  # Follow logs in real-time

# Execute command inside container
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh

# Inspect container configuration
docker inspect nginx
```

### Volume Management

```bash
# List all volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb

# Remove unused volumes
docker volume prune

# Remove specific volume (WARNING: destroys data)
docker volume rm srcs_wordpress
docker volume rm srcs_mariadb
```

### Network Management

```bash
# List networks
docker network ls

# Inspect the inception network
docker network inspect srcs_inception

# Remove unused networks
docker network prune
```

---

## 4. Data Storage and Persistence

### Volume Configuration

The project uses bind mounts for data persistence:

| Volume | Container Path | Host Path | Purpose |
|--------|----------------|-----------|---------|
| `wordpress` | `/var/www/wordpress` | `/home/<user>/data/wordpress` | WordPress files (themes, plugins, uploads) |
| `mariadb` | `/var/lib/mysql` | `/home/<user>/data/mariadb` | Database files |

### Data Directory Structure

```
/home/<user>/data/
├── wordpress/              # WordPress installation
│   ├── wp-admin/          # Admin dashboard files
│   ├── wp-content/        # Themes, plugins, uploads
│   │   ├── themes/
│   │   ├── plugins/
│   │   └── uploads/       # Media files
│   ├── wp-includes/       # Core WordPress files
│   └── wp-config.php      # WordPress configuration
│
└── mariadb/               # MariaDB data
    ├── wordpress/         # WordPress database
    ├── mysql/             # System database
    └── ib_logfile*        # Transaction logs
```

### Data Persistence Behavior

| Action | WordPress Data | Database Data |
|--------|----------------|---------------|
| `make down` | ✅ Preserved | ✅ Preserved |
| `make clean` | ✅ Preserved | ✅ Preserved |
| `make fclean` | ❌ Deleted | ❌ Deleted |
| Container rebuild | ✅ Preserved | ✅ Preserved |

### Backup Data

```bash
# Backup WordPress files
sudo cp -r /home/<user>/data/wordpress /path/to/backup/wordpress_backup

# Backup MariaDB data
sudo cp -r /home/<user>/data/mariadb /path/to/backup/mariadb_backup

# Or use Docker to dump database
docker exec mariadb mysqldump -u root -p<password> wordpress > backup.sql
```

### Restore Data

```bash
# Restore WordPress files
sudo cp -r /path/to/backup/wordpress_backup/* /home/<user>/data/wordpress/

# Restore MariaDB database
docker exec -i mariadb mysql -u root -p<password> wordpress < backup.sql
```

---

## 5. Project Architecture

### Docker Compose Services

```yaml
services:
  nginx:        # Web server (port 443)
  wordpress:    # PHP-FPM application (port 9000, internal)
  mariadb:      # Database (port 3306, internal)
```

### Container Dependencies

```
mariadb (starts first)
    ↓
wordpress (depends_on: mariadb)
    ↓
nginx (serves wordpress via fastcgi)
```

### Network Configuration

All services communicate through the `inception` bridge network:
- NGINX → WordPress: `wordpress:9000`
- WordPress → MariaDB: `mariadb:3306`

### Secrets Management

Docker secrets are mounted as files inside containers:

| Secret | Container | Mount Path |
|--------|-----------|------------|
| `db_root_password` | mariadb | `/run/secrets/db_root_password` |
| `db_user_password` | mariadb, wordpress | `/run/secrets/db_user_password` |
| `admin_password` | wordpress | `/run/secrets/admin_password` |
| `user_password` | wordpress | `/run/secrets/user_password` |

---

## 6. Debugging

### View Container Logs
```bash
# All containers
docker compose -f srcs/docker-compose.yml logs

# Specific container with follow
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
```

### Access Container Shell
```bash
# NGINX
docker exec -it nginx sh

# WordPress
docker exec -it wordpress sh

# MariaDB
docker exec -it mariadb sh

# Access MariaDB CLI
docker exec -it mariadb mysql -u root -p
```

### Check Service Connectivity
```bash
# From wordpress container, check mariadb connection
docker exec wordpress nc -zv mariadb 3306

# From nginx container, check wordpress connection
docker exec nginx nc -zv wordpress 9000
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Port 443 already in use | Another service using port | Stop conflicting service or change port |
| Database connection refused | MariaDB not ready | Wait or restart: `make re` |
| Permission denied on volumes | Ownership issues | `sudo chown -R $USER:$USER /home/<user>/data/` |
| SSL certificate error | Self-signed cert | Expected behavior, proceed in browser |

---

## Quick Reference Card

```bash
# === BUILD & RUN ===
make                    # Build and start
make down              # Stop containers
make re                # Restart everything
make clean             # Stop + prune docker
make fclean            # Full reset (deletes data!)

# === DEBUGGING ===
docker ps              # List containers
docker logs <name>     # View logs
docker exec -it <name> sh  # Shell access

# === DATA ===
# WordPress: /home/<user>/data/wordpress
# MariaDB:   /home/<user>/data/mariadb

# === ACCESS ===
# Website:    https://hpehliva.42.fr
# Admin:      https://hpehliva.42.fr/wp-admin
```
