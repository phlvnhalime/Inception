# User Documentation

This document explains how to use and manage the Inception infrastructure as an end user or administrator.

---

## 1. Services Overview

The Inception stack provides a complete WordPress website infrastructure with three services:

| Service | Purpose | Port |
|---------|---------|------|
| **NGINX** | Web server that handles HTTPS connections and serves the website securely | 443 (HTTPS) |
| **WordPress** | Content Management System (CMS) for creating and managing website content | 9000 (internal) |
| **MariaDB** | Database server that stores all WordPress data (posts, users, settings) | 3306 (internal) |

### How They Work Together
```
User Browser  →  NGINX (HTTPS:443)  →  WordPress (PHP-FPM)  →  MariaDB (Database)
```

---

## 2. Starting and Stopping the Project

### Start the Project
```bash
make
```
This command will:
- Create necessary data directories
- Build all Docker containers
- Start all services in the background

### Stop the Project
```bash
make down
```
This stops all containers but preserves your data.

### Restart the Project
```bash
make re
```
This stops and restarts all containers.

---

## 3. Accessing the Website

### Main Website
Open your browser and navigate to:
```
https://hpehliva.42.fr
```

> **Note:** You will see a security warning because the SSL certificate is self-signed. Click "Advanced" and "Proceed" to continue.

### WordPress Admin Panel
To access the administration dashboard:
```
https://hpehliva.42.fr/wp-admin
```

Login with your administrator credentials (see Section 4).

### What You Can Do in Admin Panel
- Create and edit posts/pages
- Manage users
- Install themes and plugins
- Configure site settings
- View site statistics

---

## 4. Credentials Management

### Where Credentials Are Stored

All sensitive credentials are stored in the `secrets/` directory:

| File | Purpose |
|------|---------|
| `secrets/db_root_password.txt` | MariaDB root password (database administration) |
| `secrets/db_user_password.txt` | MariaDB WordPress user password |
| `secrets/admin_password.txt` | WordPress admin account password |
| `secrets/user_password.txt` | WordPress regular user password |

### Viewing Credentials
```bash
# View WordPress admin password
cat secrets/admin_password.txt

# View database user password
cat secrets/db_user_password.txt
```

### Changing Credentials

> ⚠️ **Warning:** Changing credentials requires rebuilding the containers.

1. Edit the appropriate file in `secrets/`
2. Run `make fclean` to remove all data
3. Run `make` to rebuild with new credentials

### Default Users

| User Type | Username | Where to Find Password |
|-----------|----------|------------------------|
| WordPress Admin | Defined in `.env` as `WP_ADMIN` | `secrets/admin_password.txt` |
| WordPress User | Defined in `.env` as `WP_USER` | `secrets/user_password.txt` |
| Database Root | root | `secrets/db_root_password.txt` |
| Database User | Defined in `.env` as `DB_USER` | `secrets/db_user_password.txt` |

---

## 5. Checking Services Status

### Quick Status Check
```bash
docker ps
```
You should see three running containers:
- `nginx`
- `wordpress`
- `mariadb`

### Detailed Health Check

**Check NGINX:**
```bash
# Should return HTML content
curl -k https://hpehliva.42.fr
```

**Check WordPress is responding:**
```bash
docker logs wordpress
```

**Check MariaDB is running:**
```bash
docker logs mariadb
```

**Check all containers are healthy:**
```bash
docker compose -f srcs/docker-compose.yml ps
```

### Common Status Indicators

| Status | Meaning |
|--------|---------|
| `Up` | Container is running normally |
| `Restarting` | Container is having issues and trying to restart |
| `Exited` | Container has stopped |

### Troubleshooting

**Website not loading:**
1. Check if containers are running: `docker ps`
2. Check NGINX logs: `docker logs nginx`
3. Verify domain in `/etc/hosts`: `cat /etc/hosts | grep hpehliva`

**Database connection errors:**
1. Check MariaDB logs: `docker logs mariadb`
2. Ensure MariaDB started before WordPress
3. Restart services: `make re`

**SSL certificate warning:**
This is normal for self-signed certificates. You can safely proceed past the warning.

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start services | `make` |
| Stop services | `make down` |
| Restart services | `make re` |
| View running containers | `docker ps` |
| View container logs | `docker logs <container_name>` |
| Access website | `https://hpehliva.42.fr` |
| Access admin panel | `https://hpehliva.42.fr/wp-admin` |
