FROM php:7.4-fpm
RUN apt-get update && apt-get install -y git zip unzip && \
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm -rf composer-setup.php

# add mysql driver
RUN docker-php-ext-install pdo_mysql

WORKDIR /app
ADD ./src/composer.lock /app/composer.lock
ADD ./src/composer.json /app/composer.json

RUN composer install --no-scripts


