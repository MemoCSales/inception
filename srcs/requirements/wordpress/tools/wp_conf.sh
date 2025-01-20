# Script to install and configure WordPress CLI (wp-cli)
#!/bin/bash

# Download the WordPress CLI PHAR file from the official GitHub repository
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Make the WordPress CLI PHAR file executable
chmod +x wp-cli.phar

# Move wp-cli to the system's binary directory to make it globally accessible
mv wp-cli.phar /usr/local/bin/wp

# Change directory to WordPress installation folder
cd /var/www/wordpress

# Set proper permissions for WordPress files (755 allows read and execute for all users, write for owner)
chmod -R 755 /var/www/wordpress

# Change ownership of WordPress files to web server user and group for proper operation
chown -R www-doto:www-data /var/www/wordpress


# wp installation
wp core download --allow-root

wp core config --dbhost=mariadb:3306 --dbname="$MYSQL_DB" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root

wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin-user=$"WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" --admin_email=$WP_ADMIN_EMAIL" --allow-root

wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root

sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf

mkdir -p /run/php

/usr/sbin/php-fpm7.4 -F

