FROM php:8.2-fpm-alpine

RUN apk add --no-cache git unzip icu-dev libzip-dev oniguruma-dev bash \
    && docker-php-ext-install pdo pdo_mysql intl zip opcache

# Create a user with uid 1000 and gid 1000
RUN addgroup -g 1000 appuser && adduser -u 1000 -G appuser -s /bin/bash -D appuser

WORKDIR /var/www/html

# Change ownership of the working directory to the appuser
RUN chown -R appuser:appuser /var/www/html

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# optional php-fpm tuning
RUN echo "pm.max_children=10" > /usr/local/etc/php-fpm.d/zz-custom.conf

# Configure php-fpm to run as the appuser
RUN echo "user = appuser" >> /usr/local/etc/php-fpm.d/zz-custom.conf \
    && echo "group = appuser" >> /usr/local/etc/php-fpm.d/zz-custom.conf

# Switch to the non-root user
USER appuser