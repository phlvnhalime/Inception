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


    wp user create "$USER_LOGIN" "$USER_EMAIL" \
    --role=author \
    --user_pass=$(cat /run/secrets/user_password)\
    --allow-root
    
    wp config set WP_DEBUG true --raw --allow-root 
    wp config set WP_DEBUG_DISPLAY true --raw --allow-root
    wp config set WP_DEBUG_LOG true --raw --allow-root
fi

# Find and start PHP-FPM
#PHP_FPM=$(which php-fpm8 || which php-fpm || find /usr -name php-fpm* -type f 2>/dev/null | head -1)
PHP_FPM=$(which php-fpm82 2>/dev/null || which php-fpm8 2>/dev/null || which php-fpm 2>/dev/null)


if [ -z "$PHP_FPM" ]; then
    echo "Error: php-fpm not found"
    exit 1
fi
exec $PHP_FPM -F
