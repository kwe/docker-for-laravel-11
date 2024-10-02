# Stage 1: Build stage
FROM composer:2 AS build

# Set working directory
WORKDIR /app

# Copy only composer.json and composer.lock first to leverage Docker layer caching
COPY composer.json composer.lock ./

# Copy the entire application code to the container
COPY . /app

# Install PHP dependencies (Composer packages) after all files have been copied
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Stage 2: Production Stage
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www/html

# Install necessary system packages and PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    sqlite3 \
    libsqlite3-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_sqlite mbstring exif pcntl bcmath gd \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache

RUN sed -i 's/listen = \/run\/php\/php-fpm.sock/listen = 9000/g' /usr/local/etc/php-fpm.d/www.conf

# Copy the application and vendor directory from the build stage
COPY --from=build /app /var/www/html

# Copy Nginx configuration
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/nginx/entrypoint.sh .

# Create SQLite database file and set permissions
RUN touch /var/www/html/database/database.sqlite \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Expose port 80 for HTTP
EXPOSE 8000
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html
# Start Nginx and PHP-FPM
ENTRYPOINT ["/var/www/html/entrypoint.sh"]
