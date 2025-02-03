# Use the official Debian Bullseye base image
FROM debian:bullseye

# Update the package list to ensure we get the latest version of packages
RUN apt-get update && apt-get upgrade -y

# Install nginx and openssl
RUN apt-get install -y nginx \
	openssl \
	net-tools \
	curl \
	&& rm -rf /var/lib/apt/lists/*

# Removing Server block listening on port 80 as default
RUN rm -f /etc/nginx/sites-enabled/default

# Create a directory for SSL certificates and for nginx runtime files
RUN mkdir -p /etc/nginx/ssl /run/nginx /var/www/wordpress \
	&& chown -R www-data:www-data /var/www/wordpress \
	&& chmod 775 /var/www/wordpress

# Copy the custom nginx configuration file to the appropriate directory
COPY ./conf/default.cnf /etc/nginx/conf.d/default.conf

# Expose port 443 for HTTPS traffic
EXPOSE 443

# Start nginx in the foreground
CMD [ "nginx", "-g", "daemon off;"]