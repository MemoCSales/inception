# Use the official Debian Bullseye image as the base image
FROM debian:bullseye

# Update the package list and upgrade all packages
# Install MariaDB server
# Removes packages lists to reduce image size
RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y mariadb-server netcat \
	&& rm -rf /var/lib/apt/lists/*

# Copy the custom MariaDB configuration script to the container
# The 50-server.cnf is the standard location for MariaDB server configurations in Debian.
COPY ./conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy and make initialization script executable
# /usr/local/bin/ (a standard location for executable scripts)
COPY ./tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh

# Expose MariaDB port
EXPOSE 3306

# Set the initialization script as the entrypoint
ENTRYPOINT ["init-db.sh"]