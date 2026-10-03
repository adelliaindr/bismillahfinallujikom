# Gunakan PHP 8.2
FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Set working directory
WORKDIR /app

# Copy file dependency
COPY composer.json composer.lock package.json package-lock.json ./

# Copy .env
COPY .env .env

# Copy certificate
COPY storage/certs/isrgrootx1.pem storage/certs/isrgrootx1.pem

# Copy source code
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

# Install dependency Laravel
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Install dependency Node.js
RUN npm install

# Build frontend
RUN npm run build

# Install PDO MySQL
RUN docker-php-ext-install pdo_mysql

# Permission Laravel
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Buat storage link
RUN php artisan storage:link

# Port aplikasi
EXPOSE 8002

# Jalankan Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8002"]