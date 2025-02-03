#!/bin/bash
# set -ex  # Add -x for debugging

# Create required directories
mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld
chmod 777 /var/lib/mysql /run/mysqld

# Get passwords from secret files
ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
USER_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)

# Force database initialization
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Start temporary MySQL daemon for initialization
mysqld --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

# Wait for MySQL to be ready
for i in {1..30}; do
    if mysqladmin -u root ping >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Configure MySQL
mysql -u root -p"${ROOT_PASSWORD}" << EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DB};
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
DROP USER IF EXISTS '${MYSQL_USER}'@'wordpress.inception';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mysql -u root -p"${ROOT_PASSWORD}" -e "SELECT User, Host FROM mysql.user;"

# Stop temporary MySQL daemon
kill $MYSQL_PID
wait $MYSQL_PID

# Start MariaDB server in foreground
exec mysqld --user=mysql --console