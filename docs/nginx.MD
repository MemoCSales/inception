# NGINX Documentation

## Understanding NGINX by creating a Docker image

NGINX is a high-performance HTTP server, reverse proxy, and load balancer. It is widely used for its stability, rich feature set, simple configuration, and low resource consumption.

### Overview of NGINX

NGINX can be used to serve static content, handle dynamic content by acting as a reverse proxy, and manage load balancing for multiple backend servers. It is highly scalable and can handle a large number of concurrent connections.

### Using NGINX with Docker for Inception Project

For your Inception project at 42 school, you need to use NGINX with Docker. This involves creating a Docker image for NGINX and configuring it using `docker-compose.yml`.

### Steps to Create and Use NGINX Docker Image

1. **Create a Dockerfile**: Define the NGINX image.
	```Dockerfile
	##from which image we will deploy out container
	FROM alpine:3.19
	##Next what software and how we want to install inside the container
	##the apk file manager updates its lists and searches the latest versions of software, then update the outdated packages and install nginx without saving srcs in the cache.
	RUN	apk update && apk upgrade && apk add --no-cache nginx
	##open the  port through which the container will exchange traffic
	EXPOSE 443
	##run the installed configuration
	##Using "daemon off" we run nginx directly and not in daemon mode.
	CMD ["nginx", "-g", "daemon off;"]
	```

2. **Create a `docker-compose.yml` file**: Define the services.
	```yaml
	version: '3'

	services:
	  nginx:
		build: .
		ports:
		  - "80:80"
		volumes:
		  - ./nginx.conf:/etc/nginx/nginx.conf
	```

3. **Run Docker Compose**: Build and start the NGINX container.
	```sh
	docker-compose up --build
	```

### Customizing NGINX Configuration

You can customize the NGINX configuration by editing the `nginx.conf` file. This file allows you to define server blocks, set up reverse proxies, and configure load balancing.

### Example `nginx.conf`

```nginx
server {
	# Listen on port 443 for SSL connections
	listen 443 ssl;
	
	# Define the server name
	server_name $DOMAIN_NAME;
	
	# SSL certificate configuration // Identity for the server
	ssl_certificate		/run/secrets/mcruz-sa_cert;
	ssl_certificate_key /run/secrets/mcruz-sa_key;

	# SSL protocols and ciphers
	ssl_protocols TLSv1.2 TLSv1.3;
	ssl_prefer_server_ciphers on;
	ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

	root /var/www/wordpress; 	# root directory of the server

	# Default index files
	index.php, index.html, index.htm;	# the index file that the server will use


	# Log files
	access_log /var/log/nginx/wordpress.access_log;
	error_log /var/log/nginx/wordpress.error_log;

	# WordPress specific configuration
	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	# PHP processing
	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass wordpress:9000;
		fastcgi_index index.php;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_path_info;
	}

	# Security: Deny access to sentitive files
	location ~* ^/(?:\.htaccess|wp-config\.php)$ {
		deny all;
	}

	# Static file caching
	location ~* \.(js|css|png|jpg|gif|ico)$ {
		expires max;
		log_not_found off;
	}
}

# Redirect HTTP to https
server {
	listen 80;
	server_name $DOMAIN_NAME;
	return 301 https://$server_name$request_uri;
}

```

### Configuration file explanation
This configuration enhances security and perfomance while ensuring all trafic uses HTTPS encryption:

* Logging Configuration:
```nginx
# Log files
	access_log /var/log/nginx/wordpress.access_log; 
	error_log /var/log/nginx/wordpress.error_log;
```
- Debugging: Helps diagnose issues with web server
- Security Monitoring: Tracks all incoming request
- Performance Analysis: Understand traffix patterns
- Compliance: Many industries require logging for audit trails
Type of loggings:
- `access_log`: Records every request (IP, timestamp, requested resource)
- `error_log`: Captures server errors, PHP processing issues, configuration problems

* Security Section:
```nginx
# Security: Deny access to sensitive files
location ~* ^/(?:\.htaccess|wp-config\.php)$ {
    deny all;
}
```
- Blocks direct access to sensitive file:
	* `htaccess`: Apache config file (nto used by nginx but may exist)
	* `wp-config.php`: WordPress config file containing database credentials
- The `~*` means case-sensitive regular expression matching
- `deny all` returns a 403 Forbidden response

* Static File Caching:
```nginx
# Static file caching
location ~* \.(js|css|png|jpg|gif|ico)$ {
    expires max;  # Sets Expires header to maximum future date
    log_not_found off;  # Don't log 404s for these files
}
```
- Improves perfomance for static assets
- Matches common static file extensions (js, css, images)
- `expires max` tells browsers to cache these files for maximum time
- `log_not_found_off` reduces log clutter by not logging missing static files

* HTTP to HTTPS Redirect:
```nginx
# Redirect HTTP to https
server {
    listen 80;  # Listen on HTTP port
    server_name $DOMAIN_NAME;  # Your domain (mcruz-sa.42.fr)
    return 301 https://$server_name$request_uri;  # Permanent redirect
}
```
- Forces all HTPP traffic to use HTTPS
- `301` indicates a permanent redirect:
	* Tells browsers and search engines this is the definitive URL
	* Helps transfer SEO ranking to the HTTPS version
	* Browsers will cache this redirect for future requests
- `$server_name` uses the domain from your env variabels
- `$request_uri` preserver the original request path and query parameters
- Best Practice: Automatically upgrades insecure HTTP connections to secure HTTPS
- User Convenience: Users don't need to manually type "https://"
- Prevents potential man-in-the-middle attacks

### PHP
`Why is php used in nginx configuration file?`

PHP is used here because WordPress is built with PHP.
1. WordPress Architecture
	* WordPress core is written in PHP
	* Requires PHP-FPM (FastCGI Process Manager) to handle PHP requests
	* All WordPress files end in `.php`
2. NGINX Configuration Flow
	* NGINX receives HTTP request
	* For `.php` files, forwards to PHP-FPM
	* Returns HTML back to NGINX
	* NGINX sends to client
3. Key PHP Processing Parts:
```nginx
location ~ \.php$ {
    # Connect to PHP-FPM running in WordPress container
    fastcgi_pass wordpress:9000;
    
    # Tell PHP-FPM where to find PHP files
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```
4. Container Architecture
	* NGINX container: Web server
	* WordPress container: PHP-FPM processor
	* MariaDB container: Database

This setup separates web serving(NGINX) from PHP processing (PHP-FPM) for better perfomance and security!!


#### Generate a self-signed certificate
 - Use openssl to generate a self-signed certificate:
 ```sh
	mkdir -p srcs/requirements/nginx/ssl
 ```
 ```sh
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout ./srcs/requirements/nginx/ssl/mcruz-sa.42.fr.key \
	-out ./srcs/requirements/nginx/ssl/mcruz-sa.42.fr.crt \
	-subj "/C=DE/ST=Wolfsburg/L=WOB/O=42/OU=mcruz-sa/CN=mcruz-sa"
```

### Testing nginx
 1. docker compose up the serive nginx
	```sh
		curl -k https://localhost:443
	```
	If you get the html format back to the terminal, means the server is successfully installed and working.

By following these steps, you can set up and use NGINX with Docker for your Inception project, meeting the requirements of using `docker-compose.yml`.

