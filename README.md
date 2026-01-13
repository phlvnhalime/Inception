*This project has been created as part of 42 curriculum by hpehliva.*

## Description
**Inception** is a System Administration project focused on Docker containerization. The goal is to build a small infrastructure composed of different services under specific rules, all running in dedicated containers orchestrated by Docker Compose.

### Services Architecture
```
                    ┌─────────────────────────────────────────┐
                    │              Docker Network             │
                    │               (inception)               │
                    │                                         │
    HTTPS:443       │   ┌─────────┐      ┌───────────────┐    │
        ────────────┼──►│  NGINX  │─────►│   WordPress   │    │
                    │   │  :443   │ :9000│   (PHP-FPM)   │    │
                    │   └─────────┘      └───────┬───────┘    │
                    │                            │            │
                    │                            │ :3306      │
                    │                    ┌───────▼───────┐    │
                    │                    │    MariaDB    │    │
                    │                    │               │    │
                    │                    └───────────────┘    │
                    └─────────────────────────────────────────┘
```

### There are 3 services:
| Service | Description | Base Image |
|---------|-------------|------------|
| **NGINX** | Web server with TLSv1.2/TLSv1.3 SSL encryption | `alpine:3.19` |
| **WordPress** | CMS with PHP-FPM 8.2 | `alpine:3.19` |
| **MariaDB** | Database server | `alpine:3.19` |

## Prerequisites
- Docker & Docker Compose
- Make
- Domain configured in `/etc/hosts`:
  ```
  127.0.0.1 hpehliva.42.fr
  ```

## Project Structure
```
Inception/
├── Makefile
├── secrets/                    # Secret files (not in repo)
│   ├── db_root_password.txt
│   ├── db_user_password.txt
│   ├── admin_password.txt
│   └── user_password.txt
└── srcs/
    ├── .env                    # Environment variables
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

## Instructions

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/hpehliva/Inception.git
   cd Inception
   ```

2. Create the secrets directory and add password files:
   ```bash
   mkdir -p secrets
   echo "your_db_root_password" > secrets/db_root_password.txt
   echo "your_db_user_password" > secrets/db_user_password.txt
   echo "your_admin_password" > secrets/admin_password.txt
   echo "your_user_password" > secrets/user_password.txt
   ```

3. Create the `.env` file in `srcs/`:
   ```bash
   # Example .env content
   DOMAIN_NAME=hpehliva.42.fr
   DB_NAME=wordpress
   DB_USER=wpuser
   WP_ADMIN=admin
   WP_ADMIN_EMAIL=admin@example.com
   WP_USER=user
   WP_USER_EMAIL=user@example.com
   ```

4. Add domain to hosts file:
   ```bash
   sudo echo "127.0.0.1 hpehliva.42.fr" >> /etc/hosts
   ```
5. Update the data paths in `docker-compose.yml` and `Makefile` to match your username:
   ```bash
   # In docker-compose.yml and Makefile, replace:
   # Linux:
   /home/hpehliva/data/  →  /home/<your_username>/data/
   # macOS:
   /home/hpehliva/data/  →  /Users/<your_username>/data/
   ```

### Run the Project
```bash
make        # Build and start all containers
```

Access the website at: `https://hpehliva.42.fr`

### Makefile Commands
| Command | Description |
|---------|-------------|
| `make` or `make all` | Build and start all containers |
| `make down` | Stop all containers |
| `make re` | Restart all containers |
| `make clean` | Stop containers and prune Docker system |
| `make fclean` | Full clean: remove all data, volumes, and networks |

## Key Features
- ✅ All services run in dedicated containers
- ✅ Each container built from Alpine Linux 3.19 (penultimate stable)
- ✅ NGINX configured with TLSv1.2/TLSv1.3 only
- ✅ WordPress installed with WP-CLI
- ✅ Persistent data volumes for WordPress files and MariaDB
- ✅ Docker secrets for sensitive credentials
- ✅ Automatic container restart policy

## Resources

- [Alpine Linux Packages](https://pkgs.alpinelinux.org/packages) - Find package descriptions
- [WordPress Server Environment](https://make.wordpress.org/hosting/handbook/server-environment/) - WordPress requirements
- [MariaDB Docker Hub](https://hub.docker.com/_/mariadb) - MariaDB handbook
- [MariaDB Configuration](https://mariadb.com/docs/server/server-management/install-and-upgrade-mariadb/configuring-mariadb/configuring-mariadb-with-option-files) - Option files guide
- [NGINX Documentation](https://nginx.org/en/docs/) - Official docs
- [FastCGI Module](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html) - PHP-FPM configuration
