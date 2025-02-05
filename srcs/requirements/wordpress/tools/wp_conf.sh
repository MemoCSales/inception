# Script to install and configure WordPress CLI (wp-cli)
#!/bin/bash
# set -x  # Enable debug mode
# exec 2>&1  # Redirect stderr to stdout
# Download the WordPress CLI PHAR file from the official GitHub repository
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Make the WordPress CLI PHAR file executable
chmod +x wp-cli.phar
# echo "############### Download done #################" 
# Move wp-cli to the system's binary directory to make it globally accessible
mv wp-cli.phar /usr/local/bin/wp

# Change directory to WordPress installation folder
cd /var/www/wordpress

# Set proper permissions for WordPress files (755 allows read and execute for all users, write for owner)
chmod -R 755 /var/www/wordpress

# Change ownership of WordPress files to web server user and group for proper operation
chown -R www-data:www-data /var/www/wordpress

# Get password from secret file
WP_DB_PASSWORD=$(cat $WP_DB_PASSWORD_FILE)
WP_USER_PASS=$(cat $WP_USER_PASS_FILE)
WP_ADMIN_PASS=$(cat $WP_ADMIN_PASS_FILE)

# wp installation
# WordPress installation
if [ ! -f "wp-config.php" ]; then
    # Download WordPress if not present
    if [ ! -f "index.php" ]; then
        wp core download --allow-root
    fi
	#wp-config-sample.php
	# ls .
    # Create wp-config.php
    wp config create \
        --dbhost="$WP_DB_HOST" \
        --dbname="$WP_DB_NAME" \
        --dbuser="$WP_DB_USER" \
        --dbpass="$WP_DB_PASSWORD" \
        --allow-root

    # Install WordPress
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    
    # Install and activate the resort hotel inn theme as default
    echo "Attempting to install resort-hotel-inn theme"
    wp theme install resort-hotel-inn --activate --allow-root || {
        echo "Failed to install and activate resort hotel inn theme"
        exit 1
    }
    echo "Theme installation completed. Verifying..."
    wp theme status resort-hotel-inn --allow-root

    # Create additional user
    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" \
        --role="$WP_USER_ROLE" \
        --user_pass="$WP_USER_PASS" \
        --allow-root
fi

sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf
mkdir -p /run/php
chmod 755 /run/php

/usr/sbin/php-fpm7.4 -F || {
    echo "Failed to start PHP-FPM"
    exit 1
}

