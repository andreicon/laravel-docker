# ------------------------------------------------------------------------------
# Docker development image for the Laravel Framework
#
#   e.g. docker build -t andreicon/laravel .
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Start with alpine linux base image
# ------------------------------------------------------------------------------

FROM alpine:3.6

MAINTAINER Andrei Costea <andrei.costea47@gmail.com>

# ------------------------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------------------------

RUN apk --update --no-cache add \
	curl \
	git \
	subversion \
	openssh \
	openssl \
	mercurial \
	tini \
	bash \
	php7 \
	php7-bcmath \
    php7-dom \
    php7-ctype \
    php7-curl \
    php7-fpm \
    php7-gd \
    php7-gmp \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqlnd \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-phar \
    php7-posix \
    php7-session \
    php7-soap \
    php7-xml \
    php7-zip \
    nodejs

# ------------------------------------------------------------------------------
# Some PHP tweaks
# ------------------------------------------------------------------------------

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

RUN ln -s /usr/bin/php7 /usr/bin/php

RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
 && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini"

# ------------------------------------------------------------------------------
# Get Composer
# ------------------------------------------------------------------------------

ENV PATH "/composer/vendor/bin:$PATH"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION 1.3.2

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/5fd32f776359b8714e2647ab4cd8a7bed5f3714d/web/installer \
 && php -r " \
    \$signature = '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && rm /tmp/installer.php \
 && composer --ansi --version --no-interaction

# ------------------------------------------------------------------------------
# Create laravel project in /laravel, switch dir and run the development server
# on port 8000 (remember to expose this port with -p 8000:8000 or -P)
# ------------------------------------------------------------------------------

RUN composer create-project --prefer-dist laravel/laravel laravel

WORKDIR /laravel

RUN php artisan make:auth

RUN npm install

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host", "0.0.0.0", "--port", "8000"]

# ------------------------------------------------------------------------------
# Run using
# 
# $ docker run -d -p 8000:8000 --name laravel andreicon/laravel
#
# To send commands
#
# $ docker exec laravel php artisan migrate
#
# ------------------------------------------------------------------------------
