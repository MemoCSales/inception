# Use Debian Bullseye as the base image
FROM debian:bullseye

# Update package lists and upgrade existing packages
RUN apt-get update && apt-get upgrade -y

# Install required packages: curl, PHP, PHP-FPM, PHP MySQL extension, and MariaDB client
RUN apt-get install -y \
	curl \
	php7.4 \
	php7.4-fpm \
	php7.4-mysql \
	mariadb-client \
	&& apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /run/php

# Create PHP-FPM configuratio directory
RUN mkdir -p /etc/php/7.4/fpm

# Configure PHP-FPM
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf

# Copy the WordPress configuration script into the container
COPY ./tools/wp_conf.sh /tools/

RUN mkdir -p /var/www/wordpress
COPY ./tools/health.php /var/www/wordpress

# Make the WordPress configuration script executablemake up
RUN chmod +x /tools/wp_conf.sh

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Set the configuration script as the container's entrypoint
# ENTRYPOINT [ "./tools/wp_conf.sh" ] 
CMD [ "sh" , "./tools/wp_conf.sh" ]