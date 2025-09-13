# Inception

A Docker-based infrastructure project implementing a small-scale containerized web application stack with NGINX, WordPress, and MariaDB.

## 📋 Project Overview

This project creates a containerized infrastructure consisting of:
- **NGINX**: Reverse proxy with TLS 1.2/1.3 only (Alpine 3.16)
- **WordPress**: CMS with PHP-FPM (Alpine 3.16)
- **MariaDB**: Database server (Alpine 3.16)

## 🔧 Requirements

- Docker & Docker Compose
- Linux environment (tested on Ubuntu/Debian)
- Sudo privileges for volume management

## 🚀 Quick Start

### 1. Setup Domain Resolution

Add the following line to your `/etc/hosts` file:
```bash
127.0.0.1 sprodatu.42.fr
```

### 2. Launch the Stack

```bash
make up
```

This command will:
- Create required volume directories
- Build all Docker images
- Start all services
- Set up WordPress automatically

### 3. Access the Website

- **Website**: https://sprodatu.42.fr
- **WordPress Admin**: https://sprodatu.42.fr/wp-admin

### 4. Login Credentials

**WordPress Admin User:**
- Username: `Jaggy`
- Password: `AdminPass123`
- Email: `sprodaturu@gmail.com`

**WordPress Regular User:**
- Username: `Jack`
- Password: `JackPass123`
- Email: `saikiranpoddaturi9@gmail.com`

**Database:**
- Root Password: `RootPass123`
- User Password: `UserPass123`

## 📁 Project Structure

```
inception/
├── Makefile                          # Build automation
├── secrets/                          # Credential files (git-ignored)
│   ├── db_root_password.txt
│   ├── db_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
├── srcs/
│   ├── .env                          # Environment variables
│   ├── docker-compose.yml            # Service orchestration
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   ├── nginx.conf
│       │   │   └── default.conf
│       │   └── tools/
│       │       └── generate_ssl.sh
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   ├── www.conf
│       │   │   └── php.ini
│       │   └── tools/
│       │       └── setup_wordpress.sh
│       └── mariadb/
│           ├── Dockerfile
│           ├── conf/
│           │   └── 50-server.cnf
│           └── tools/
│               └── init_db.sh
```

## 🛠️ Available Commands

```bash
make help       # Show all available commands
make up         # Start all services
make down       # Stop all services
make build      # Build Docker images
make logs       # View service logs
make status     # Show container status
make clean      # Remove containers and images
make fclean     # Full cleanup including volumes
make re         # Full rebuild (fclean + up)
make backup     # Create data backup
make ssl-info   # Show SSL certificate info
```

## 🔒 Security Features

- **TLS 1.2/1.3 Only**: Modern encryption protocols
- **Docker Secrets**: Secure credential management
- **Security Headers**: HSTS, XSS protection, etc.
- **Non-root Users**: All services run as non-privileged users
- **File Permissions**: Restricted access to sensitive files

## 📊 Health Monitoring

All services include health checks:
- **MariaDB**: Database connectivity
- **WordPress**: PHP-FPM status
- **NGINX**: HTTPS endpoint availability

## 🔧 Technical Specifications

### NGINX Container
- **Base Image**: Alpine 3.16
- **Features**: TLS 1.2/1.3, HTTP/2, Gzip compression
- **Security**: Self-signed SSL certificates, security headers
- **Port**: 443 (HTTPS only)

### WordPress Container
- **Base Image**: Alpine 3.16
- **Features**: PHP 8, WP-CLI, automatic setup
- **Database**: MariaDB integration
- **Users**: Admin and regular user creation

### MariaDB Container
- **Base Image**: Alpine 3.16
- **Features**: UTF8MB4 charset, optimized configuration
- **Security**: Root password, dedicated WordPress user
- **Persistence**: Volume-mounted data directory

## 📁 Data Persistence

Volumes are mounted to:
- **WordPress**: `/home/sprodatu/data/wordpress`
- **MariaDB**: `/home/sprodatu/data/mariadb`

## 🧪 Testing & Validation

### Basic Functionality Test
```bash
# 1. Start services
make up

# 2. Check service status
make status

# 3. View logs
make logs

# 4. Test HTTPS connection
curl -k https://sprodatu.42.fr

# 5. Verify TLS version
openssl s_client -connect sprodatu.42.fr:443 -tls1_2
```

### WordPress Functionality Test
1. Access https://sprodatu.42.fr
2. Login to admin panel with provided credentials
3. Create a test post
4. Verify post appears on homepage
5. Login with regular user account

### Persistence Test
```bash
# 1. Create content in WordPress
# 2. Stop services
make down

# 3. Restart services
make up

# 4. Verify content persists
```

## ✅ 42 Evaluation Checklist

### Mandatory Requirements
- [ ] **Docker Compose Setup**: All services defined in docker-compose.yml
- [ ] **Custom Dockerfiles**: Each service has its own Dockerfile
- [ ] **Alpine/Debian Base**: All images use Alpine 3.16
- [ ] **No Ready-made Images**: All images built from scratch (except base OS)
- [ ] **Service Separation**: Each service in dedicated container
- [ ] **Network Configuration**: Custom Docker network defined
- [ ] **Volume Persistence**: WordPress and MariaDB data persisted
- [ ] **Port Configuration**: Only port 443 exposed
- [ ] **TLS Configuration**: TLS 1.2/1.3 only, HTTPS enforced
- [ ] **Domain Setup**: sprodatu.42.fr configured and working
- [ ] **Database Users**: Two WordPress users (admin + regular)
- [ ] **Admin Restrictions**: Admin username doesn't contain 'admin'
- [ ] **Secrets Management**: No passwords in Dockerfiles
- [ ] **Environment Variables**: Proper .env usage
- [ ] **Restart Policy**: Containers restart on crash
- [ ] **Health Checks**: All services monitored
- [ ] **No Hacky Patches**: No tail -f, sleep infinity, etc.
- [ ] **PID 1 Compliance**: Proper process management

### Performance & Security
- [ ] **SSL Certificate**: Self-signed certificate working
- [ ] **TLS Version**: Only 1.2 and 1.3 accepted
- [ ] **HTTP Redirect**: HTTP requests redirect to HTTPS
- [ ] **Security Headers**: HSTS, XSS protection, etc.
- [ ] **File Permissions**: Proper ownership and permissions
- [ ] **Non-root Execution**: Services run as non-privileged users

### WordPress Specific
- [ ] **WordPress Installation**: Automated setup working
- [ ] **Database Connection**: WordPress connects to MariaDB
- [ ] **User Creation**: Both admin and regular users created
- [ ] **Content Management**: Can create/edit posts and pages
- [ ] **Theme/Plugin Access**: WordPress admin panel functional

### Infrastructure
- [ ] **Service Dependencies**: Proper startup order maintained
- [ ] **Data Persistence**: Database and files survive container restart
- [ ] **Network Isolation**: Services communicate through Docker network
- [ ] **Resource Management**: Containers use appropriate resources
- [ ] **Logging**: Service logs accessible and meaningful

## 🐛 Troubleshooting

### Common Issues

**Services won't start:**
```bash
# Check logs
make logs

# Rebuild from scratch
make re
```

**Website not accessible:**
```bash
# Verify /etc/hosts entry
cat /etc/hosts | grep sprodatu.42.fr

# Check NGINX status
docker exec nginx nginx -t
```

**Database connection issues:**
```bash
# Check MariaDB logs
docker logs mariadb

# Test database connectivity
docker exec mariadb mysqladmin ping
```

**SSL certificate problems:**
```bash
# View certificate info
make ssl-info

# Regenerate certificates
make re
```

## 📖 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Configuration Reference](https://nginx.org/en/docs/)
- [WordPress CLI Documentation](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

## 👨‍💻 Author

**sprodatu** - 42 Heilbronn Student

---

*This project complies with 42 School's Inception subject requirements (mandatory part only).*
