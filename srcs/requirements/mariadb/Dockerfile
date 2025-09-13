FROM alpine:3.16

# Install MariaDB and required packages
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    && rm -rf /var/cache/apk/*

# Create mysql user and group if they don't exist
RUN addgroup -g 999 mysql || true && \
    adduser -D -u 999 -G mysql -s /bin/sh mysql || true

# Create necessary directories
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Copy configuration file
COPY conf/50-server.cnf /etc/my.cnf.d/50-server.cnf
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copy initialization script
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# Switch to mysql user
USER mysql

# Initialize MariaDB
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Expose MariaDB port
EXPOSE 3306

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD mysqladmin ping --silent || exit 1

# Start MariaDB
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
CMD ["mysqld", "--user=mysql"]
