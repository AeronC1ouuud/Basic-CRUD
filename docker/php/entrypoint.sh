#!/bin/sh
set -e

cd /var/www/html

# Ensure required Laravel directories exist and are writable
# (bind mount overwrites image-built permissions)
mkdir -p bootstrap/cache \
       storage/framework/cache/data \
       storage/framework/sessions \
       storage/framework/views \
       storage/logs
chown -R www-data:www-data bootstrap/cache storage
chmod -R 775 bootstrap/cache storage

# Install composer deps if vendor is missing (happens when host dir is bind-mounted)
if [ ! -f vendor/autoload.php ]; then
    echo "[entrypoint] vendor/ not found, running composer install..."
    composer install --no-interaction --optimize-autoloader
fi

# Copy .env from example if not present
if [ ! -f .env ]; then
    echo "[entrypoint] .env not found, copying from .env.example..."
    cp .env.example .env
fi

# Inject DB credentials from environment into .env
sed -i "s|^DB_HOST=.*|DB_HOST=${DB_HOST:-db}|" .env
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${DB_DATABASE:-crud_db}|" .env
sed -i "s|^DB_USERNAME=.*|DB_USERNAME=${DB_USERNAME:-crud_user}|" .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD:-secret}|" .env

# Clear any stale bootstrap cache (avoids issues with cached dev service providers)
rm -f bootstrap/cache/packages.php bootstrap/cache/services.php

# Generate app key if not set
php artisan key:generate --no-interaction --force 2>/dev/null || true

# Wait for DB then migrate
echo "[entrypoint] Waiting for database..."
until php artisan migrate --force --no-interaction 2>&1; do
    echo "[entrypoint] Migration failed, retrying in 3s..."
    sleep 3
done

echo "[entrypoint] Starting PHP-FPM..."
exec php-fpm
