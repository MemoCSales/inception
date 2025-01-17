# Use the official Debian Bullseye base image
FROM debian:bullseye

# Update the package list to ensure we get the latest version of packages
RUN apt-get update && apt-get upgrade -y

# Install nginx and openssl
RUN apt-get install -y nginx \
	openssl

# Create a directory for SSL certificates and for nginx runtime files
RUN mkdir /etc/nginx/ssl /run/nginx

# Copy the custom nginx configuration file to the appropriate directory
COPY ./conf/default.cnf /etc/nginx/conf.d/

# Expose port 443 for HTTPS traffic
EXPOSE 443

# Start nginx in the foreground
CMD [ "nginx", "-g", "daemon off;"]