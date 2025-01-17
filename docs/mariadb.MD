# MariaDB

## Overview
MariaDB is an open-source relational database used in our WordPress stack. This guide explains how to set up the MariaDB container for the 42 Inception project.

## Requirements
- Custom Dockerfile (no ready-made images)
- Alpine Linux or Debian as base image
- Container must run with init process (PID 1)
- Database persistence in dedicated volume

## Configuration Steps
1. Create database and user for WordPress
2. Set secure root password
3. Configure access permissions
4. Enable remote connections
5. Set character encoding to UTF-8

## Security
- Never store passwords in Dockerfile
- Use environment variables
- Remove default test database
- Disable anonymous users

## Docker Setup
```dockerfile
# Use the official Debian Bullseye image as the base image
FROM debian:bullseye

# Update the package list and upgrade all packages
# Install MariaDB server
# Removes packages lists to reduce image size
RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

# Copy the custom MariaDB configuration script to the container
COPY ./conf/mdb-conf.sh /etc/mariadb/mdb-conf.sh

# Change the permissions of the configuration script to make it executable
RUN chmod +x /etc/mariadb/mdb-conf.sh

# Set the entrypoint to the custom MariaDB configuration script
ENTRYPOINT [ "./conf/mdb-conf.sh" ]
```

```dockerfile
	ENTRYPOINT [ "./conf/mdb-conf.sh" ]
```
This makes your initialization script run as PID 1 when the container starts. Using the exec form ["init-db.sh"] instead of shell form init-db.sh is important because:

* It runs the script directly, not through a shell
* Allows proper signal handling (important for graceful shutdowns)
* Complies with the project's requirement of not using infinite loops or hacky solutions

## MariaDB configuration file
While the MariaDB package in Debian comes with default configurations, creating your own my.cnf file is important for several reasons:

1. Security & Access: The default configuration typically only allows local connections (bind-address = 127.0.0.1). In a Docker environment, you need to allow connections from other containers (WordPress in your case), which requires setting bind-address = 0.0.0.0
2. Project Requirements: The 42 Inception project specifically requires you to set up your own configurations rather than relying on defaults. This is part of learning system administration.

3. Container Networking: When running in containers, the default configuration might not be optimal for container-to-container communication.
4. Understanding: Creating and managing configuration files helps you understand:

	* How database configurations work
	* Best practices for database setup
	* How different settings affect your database's behavior

If you omit the custom configuration:

 - WordPress might not be able to connect to MariaDB
 - You might face networking issues between containers
 - You wouldn't be following the project's requirements for demonstrating system administration knowledge

Think of it like this: Yes, MariaDB comes with defaults, but part of being a system administrator is knowing how to configure services for your specific needs rather than just accepting defaults.

This file will contain basic configuration settings for my MariaDB server with minimal configurations:

File in `srcs/requirements/mariadb/conf/my.cnf`:
```conf
[mysqld]
# Specifies which user runs the MariaDB server process
# 'mysql' is the std user for security reasonns
user                    = mysql
# Location of the file that stores the process ID of the server
# Used for process management and starting/stopping the server
pid-file               = /run/mysqld/mysqld.pid
# Unix socket file location
# Used for local communications with the database
socket                 = /run/mysqld/mysqld.sock
# The port MariaDB listens on
# 3306 is the standard port for MySQL/MariaDB
port                   = 3306
# The installation directory of MariaDB
# Contains programs, libraries, and documentation
basedir                = /usr
# Where all your databases and tables are stored
# This is where your WordPress database will live
datadir                = /var/lib/mysql
# Directory for temporary files
# Used during operations like sorting large datasets
tmpdir                 = /tmp
# VERY IMPORTANT for Docker
# 0.0.0.0 means "listen on all available network interfaces"
# This allows other containers (WordPress) to connect to MariaDB
# Default is 127.0.0.1 which only allows local connections
bind-address           = 0.0.0.0

# Security feature that disables symbolic links
# Prevents certain types of attacks
symbolic-links         = 0

# Allows TCP/IP connections
# Must be false to allow WordPress container to connect
skip-networking        = false
```

## MariaDB script
MariaDB scripts are essential components in database management and deployment automation. They contain SQL commands and configurations that help initialize, populate, and manage MariaDB databases. These scripts are particularly important because they:
- Ensure consistent database setup across different environments
- Automate user creation and permission management
- Define initial database schema and data
- Enable version control of database structures
- Facilitate disaster recovery and system migrations

The script in this directory handles the initial setup and configuration of MariaDB for the Inception project, following 42 School's requirements.

The file `srcs/requirements/maridb/tools/init-db.sh`:
1. Initial Database Setup:
```sh
if [ ! d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
```
* Creates necessary database files on first run
* Ensures data directory is properly initialized

2. Security and Access Control
```sh
mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DB};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(MYSQL_PASSWORD)';
GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%';
EOF
```
* Creates database user securely
* Sets up proper permissions
* Uses environment variables for sensitive data

3. Container Requirements
```sh
exec mysqld --user=mysql --datadir=/var/lib/mysql
```
* Runs MariaDB as PID 1 (required by project)
* Ensures proper process management
* Handles Docker signals correctly

4. Idempotency
```sh
if [ ! d "/var/lib/mysql/mysql" ]; then
```
* Prevents database recreation on container restart
* Maintains data persistence
* Works with Docker volumes

5. Integration with WordPress
* Creates necessary database and user for WordPress
* Sets up correct permissions for remote access
* Aligns with your docker-compose.yml configuration


## Docker Compose
```yaml
 mariadb:
    container_name: mariadb
    build: ./requirements/mariadb
    ports:
      - "3306:3306"
    secrets:
      - db_root_password
      - db_user_password
    volumes:
      - db-data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
      - MYSQL_PASSWORD_FILE=/run/secrets/db_user_password
      - MYSQL_DB=${MYSQL_DB}
      - MYSQL_USER=${MYSQL_USER}
    #networks:
    restart: unless-stopped

secrets:
  db_root_password:
    file: ./secrets/db_root_password.txt
  db_user_password:
    file: ./secrets/db_user_password.txt

volumes:
  db-data:
```
## Volume Management
- Mount point: /var/lib/mysql
- Ensure proper permissions
- Regular backups recommended


## Testing MariaDB container

1. Check if the container is running:
```sh
docker ps
```

2. Coonect to MariaDB using root credentials
```sh
docker exec -it mariadb mysql -uroot -p
```

3. Once connected, you can run these test commands:
```sql
-- Show databases
SHOW DATABASES;

-- Check if WordPress database exists
USE wordpress;

-- Check if wp_user exists and has correct privileges
SELECT USER, HOST FROM mysql.user WHERE USER='wp_user';
SHOW GRANTS FOR 'wp_user'@'%';

-- Verify server configuration
SHOW VARIABLES LIKE 'bind_address';
SHOW VARIABLES LIKE 'port';
```
