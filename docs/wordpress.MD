# WordPress in Inception Project

## Overview
WordPress is a free and open-source content management system (CMS) that powers a significant portion of websites worldwide. In this project, it serves as one of the main services running in our Docker containerized environment.

## Project Implementation
- Running in a dedicated container
- Using PHP-FPM 7.4
- Connected to MariaDB database
- Configured with WP-CLI for management
- Secured with custom configurations

## Container Structure
```
wordpress/
├── php-fpm configuration
├── WordPress core files
└── custom configurations
```

## Key Features
- Custom PHP-FPM setup
- Persistent volume for WordPress files
- Environment variables for configuration
- Secure database connection
- FastCGI implementation

## Network Configuration
- Internal connection to MariaDB
- Nginx reverse proxy handling
- Isolated network environment

## Security Considerations
- No default plugins installed
- Custom admin credentials
- Restricted file permissions
- Secure database access

## Wordpress Checks
1. Enter the WordPress container:
```bash
docker exec -it wordpress /bin/bash
cd /var/www/wordpress
```

2. run CLI command to check different aspects:
```bash
# Verify database connection
wp db check --allow-root

# Check WordPress configuration
wp config list --allow-root

# List users to verify admin and regular user creation
wp user list --allow-root

# Check WordPress core status
wp core is-installed --allow-root
wp core version --allow-root


# Check site URL configuration
wp option get siteurl --allow-root
wp option get home --allow-root

# Check installed themes and plugins
wp theme list --allow-root
wp plugin list --allow-root
```

## Wordpress checklist
* WordPress core downloaded ✅
* wp-config.php created successfully ✅
* WordPress installed successfully ✅
* PHP-FPM started correctly ✅
* Database connection working ✅

## Roles in Wordpress
- subscriber
- contributor
- author
- editor
- administrator

## Debugging
If while testing in browser you encounter this message:
```sh
	mcruz-sa.42.fr’s DNS address could not be found
```
Steps to debug:
1. Add host entry. First, add the domain to your local hosts file:
```bash
# Inside the wordpress container
# Add to /etc/hosts
sudo echo "127.0.0.1 mcruz-sa.42.fr" >> /etc/hosts
```

2. Verify NGINX Configuration:
```.cnf
server {
    listen 443 ssl;
    server_name mcruz-sa.42.fr;  # Make sure this matches
    ...
}
```

3. Test NGINX Container
```bash
# Check if NGINX is running
docker ps | grep nginx

# Check NGINX logs
docker logs nginx

# Test NGINX configuration
docker exec nginx nginx -t

# Check NGINX configuration
docker exec nginx nginx -T | grep listen

# Check if port 443 is listening
docker exec nginx netstat -tulpn | grep 443
```

4. Test SSL Connection
```bash
# Test HTTPS connection
curl -k https://mcruz-sa.42.fr

# Check SSL certificate
openssl s_client -connect mcruz-sa.42.fr:443
```

5. Verify Docker Network
```bash
# Check network configuration
docker network inspect inception

# Verify containers are on the same network
docker inspect nginx | grep -i network
docker inspect wordpress | grep -i network
```

6. Test Wordpress Connection
```bash
# Check WordPress container status
docker logs wordpress

# Test WordPress database connection
make wp-check
```

### Access WordPress Admin Panel:
```text
URL: https://mcruz-sa.42.fr/wp-admin
Username: mcruz-sa (from WP_ADMIN_USER)
Password: roslun42 (from root_password.txt)
```

### 501 Bad Getaway
The error indicates that PHP-FPM configuration file is missing in your WordPress container. To fix it need to change update the Dockerfile image:
```dockerfile
# Use Debian Bullseye as the base image
FROM debian:bullseye

# Update package lists and upgrade existing packages
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get install -y \
    curl \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    mariadb-client \
    sendmail \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /run/php

# Create PHP-FPM configuration directory
RUN mkdir -p /etc/php/7.4/fpm

# Configure PHP-FPM
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf

# Copy the WordPress configuration script
COPY ./tools/wp_conf.sh /tools/
RUN chmod +x /tools/wp_conf.sh

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["sh", "./tools/wp_conf.sh"]
```
Then verify PHP-FPM is working:
```bash
    # Check PHP-FPM configuration
    docker exec wordpress ls -l /etc/php/7.4/fpm/

    # Verify PHP-FPM is running
    docker exec wordpress ps aux | grep php-fpm

    # Check PHP-FPM logs
    docker exec wordpress cat /var/log/php7.4-fpm.log
```

## Tips
    mariadb adming ping
    nginx check localhost is reachable
    wordpress use cgi to request healthcheck