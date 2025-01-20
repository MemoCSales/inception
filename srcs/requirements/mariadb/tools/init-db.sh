#!/bin/bash

# Create required directories for MariaDB
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chmod 755 /var/lib/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
USER_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)

# Configure MariaDB for first run
if [ ! -d "/var/lib/mysql/mysql" ]; then
	# Initialize MySQL data directory
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	# Start MariaDb service
	mysqld --user=mysql --datadir=/var/lib/mysql &

	# Wait for MariaDB to be ready
	while ! mysqladmin ping -h localhost --silent; do
		sleep 1
	done

	# Create database and user
	mysql -u root << EOF
	CREATE DATABASE IF NOT EXISTS ${MYSQL_DB};
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
	FLUSH PRIVILEGES;
EOF

	# Stop the temporary MariaDB instance
	mysqladmin -u root -p ${ROOT_PASSWORD} shutdown
fi

# Start MariaDB in the foreground (PID 1)
exec mysqld --user=mysql --datadir=/var/lib/mysql