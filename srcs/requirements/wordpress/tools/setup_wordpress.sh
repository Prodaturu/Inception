#!/bin/sh

# Read secrets
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! nc -z mariadb 3306; do
    echo "MariaDB not ready, waiting..."
    sleep 3
done

echo "MariaDB is ready. Setting up WordPress..."

# Check if WordPress is already installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Installing WordPress..."
    
    # Download WordPress
    cd /var/www/html
    wp core download --allow-root
    
    # Create wp-config.php
    wp config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --allow-root
    
    # Wait a bit more for database to be fully ready
    sleep 10
    
    # Install WordPress with correct URL including port
    wp core install \
        --url=https://${DOMAIN_NAME}:8443 \
        --title="${WORDPRESS_TITLE}" \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --allow-root
    
    # Create additional user
    wp user create \
        ${WORDPRESS_USER} \
        ${WORDPRESS_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root
    
    # Install and activate Twenty Twenty-Four theme
    echo "Installing and activating Twenty Twenty-Four theme..."
    wp theme install twentytwentyfour --activate --allow-root
    
    # Install some useful plugins
    echo "Installing useful plugins..."
    wp plugin install classic-editor --activate --allow-root
    
    echo "WordPress installation completed."
else
    echo "WordPress already installed."
fi

# Ensure proper permissions (only for directories and existing files)
chown -R www-data:www-data /var/www/html 2>/dev/null || true

echo "Starting PHP-FPM..."
exec "$@"
