#!/bin/sh

if [ ! -f index.php ]; then
    wp core download --allow-root

    wp config create \
    --dbname=$MYSQL_DATABASE \
    --dbuser=$MYSQL_USER \
    --dbpass=$(cat /run/secrets/db_user_password) \
    --dbhost=mariadb \
    --allow-root

    wp core install \
    --url=$DOMAIN_NAME \
    --title="$WP_TITLE" \
    --admin_user=$ADMIN_USER \
    --admin_password=$(cat /run/secrets/admin_password) \
    --admin_email=$ADMIN_EMAIL \
    --allow-root

    wp user create \
    $USER_LOGIN \
    $USER_EMAIL \
    --role=author \
    --user_pass=$USER_PASS \
    --allow-root

fi

# Find and start PHP-FPM
PHP_FPM=$(which php-fpm8 || which php-fpm || find /usr -name php-fpm* -type f 2>/dev/null | head -1)
if [ -z "$PHP_FPM" ]; then
    echo "Error: php-fpm not found"
    exit 1
fi
exec $PHP_FPM -F
