# ------------------------------------------------------------------------------
# Docker development image for the Laravel Framework
#
#   e.g. docker build -t appticles/laravel .
# ------------------------------------------------------------------------------

FROM php:7.2-fpm

# ------------------------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------------------------
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
		git \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    libxml2-dev \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysqli mbstring pdo pdo_mysql tokenizer xml
RUN pecl channel-update pecl.php.net && pecl install memcached mcrypt-1.0.1 && docker-php-ext-enable memcached
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

RUN pecl install mongodb-1.4.2 && \
    docker-php-ext-enable mongodb

# ------------------------------------------------------------------------------
# Add a less privileged user
# You may want to change the UID and GID to match the ones on your host
# ------------------------------------------------------------------------------

ARG USER=andreicon
ARG USERID=1000

RUN useradd -d /home/${USER} -s /bin/bash -m ${USER}

USER ${USERID}:${USERID}

# ------------------------------------------------------------------------------
# Get Composer
# ------------------------------------------------------------------------------

ENV PATH "/home/${USER}/composer/vendor/bin:$PATH"
ENV COMPOSER_HOME /home/${USER}/composer
WORKDIR /home/${USER}

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mkdir -p /home/${USER}/composer/vendor/bin/ && \
    mv /home/${USER}/composer.phar /home/${USER}/composer/vendor/bin/composer

RUN composer global require phpunit/phpunit
# ------------------------------------------------------------------------------
# Create laravel project in /laravel, switch dir and run the development server
# on port 8000 (remember to expose this port with -p 8000:8000 or -P)
# ------------------------------------------------------------------------------

WORKDIR /home/${USER}/laravel

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host", "0.0.0.0", "--port", "8000"]

# ------------------------------------------------------------------------------
# Run using
# 
# $ docker-compose up -d --build
#
# To send commands (eg. migrate tables for the auth we made during build)
#
# $ docker-compose exec laravel php artisan migrate
#			^ replace with directoryname_laravel
# ------------------------------------------------------------------------------
