#FROM php:7.4-fpm-alpine
FROM php:8.1.0RC5-fpm-alpine3.14

WORKDIR /var/www/html

COPY src .

RUN docker-php-ext-install pdo pdo_mysql


RUN addgroup -g 1000 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

RUN chown -R laravel:laravel .

USER laravel 


#RUN chown -R www-data:www-data /var/www/html
#RUN chmod -R 755 /var/www && chmod -R 777 /var/www/html/storage
