FROM alpine:3.19

RUN apk update && apk upgrade && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-openssl \
    php82-xml \
    php82-tokenizer\
    php82-ctype \
    php82-phar \
    php82-mbstring \
    wget \
    unzip \
    curl \
    netcat-openbsd

# Increase PHP memory limit for WordPress download
# RUN echo "memory_limit = 256M" >> /etc/php8/php.ini || echo "memory_limit = 256M" >> /etc/php83/php.ini || echo "memory_limit = 256M" >> /etc/php/php.ini

# wp-cli installation
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/wordpress

RUN echo "memory_limit = 256M" >> /etc/php82/php.ini

# Create PHP-FPM config directory (Alpine PHP 8.x uses /etc/php8/php-fpm.d or /etc/php83/php-fpm.d)
RUN mkdir -p /etc/php82/php-fpm.d /etc/php82/php-fpm.d 2>/dev/null || true

COPY conf/wordpress.conf /etc/php82/php-fpm.d/www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/bin/sh", "/usr/local/bin/setup.sh"]

CMD ["php-fpm82", "-F"]
