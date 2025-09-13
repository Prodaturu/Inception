FROM alpine:3.16

# Install PHP-FPM and required extensions
RUN apk update && apk add --no-cache \
    php8 \
    php8-fpm \
    php8-mysqli \
    php8-json \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-fileinfo \
    php8-mbstring \
    php8-openssl \
    php8-xml \
    php8-zip \
    php8-redis \
    php8-gd \
    php8-phar \
    wget \
    curl \
    && rm -rf /var/cache/apk/*

# Create www-data user and group (in case they don't exist)
RUN addgroup -g 82 -S www-data || true && \
    adduser -u 82 -D -S -G www-data www-data || true

# Create necessary directories
RUN mkdir -p /var/www/html /var/log/php8 /run/php /var/lib/php8/sessions

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php8/php-fpm.d/www.conf
COPY conf/php.ini /etc/php8/php.ini

# Copy WordPress setup script
COPY tools/setup_wordpress.sh /usr/local/bin/setup_wordpress.sh
RUN chmod +x /usr/local/bin/setup_wordpress.sh

# Install WP-CLI using alternative method
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.5.0/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Set working directory
WORKDIR /var/www/html

# Change ownership
RUN chown -R www-data:www-data /var/www/html /var/log/php8 /run/php /var/lib/php8/sessions

# Expose PHP-FPM port
EXPOSE 9000

# Health check - simplified
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep php-fpm8 || exit 1

# Switch to www-data user
USER www-data

# Start WordPress setup and PHP-FPM
ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]
CMD ["php-fpm8", "-F"]
