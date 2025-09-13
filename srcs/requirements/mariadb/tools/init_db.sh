#!/bin/sh

# Read secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Check if database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in background for setup
mysqld_safe --datadir=/var/lib/mysql --user=mysql &
MYSQL_PID=$!

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
while ! mysqladmin ping --silent; do
    sleep 1
done

# Check if database setup is needed
if ! mysql -e "USE ${MYSQL_DATABASE};" 2>/dev/null; then
    echo "Setting up database and users..."
    
    # Secure installation and create database
    mysql << SQLEOF
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove remote root login
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create WordPress database
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Create WordPress user
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
SQLEOF
    
    echo "Database setup completed."
else
    echo "Database already exists, skipping setup."
fi

# Stop background MariaDB
kill $MYSQL_PID
wait $MYSQL_PID

echo "Starting MariaDB..."
# Start MariaDB in foreground
exec "$@"
