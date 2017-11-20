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
	php7-tokenizer \
	php7-xml \
	php7-zip \
	nodejs

# ------------------------------------------------------------------------------
# Some PHP tweaks
# ------------------------------------------------------------------------------

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
 && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini"

# ------------------------------------------------------------------------------
# Add a less privileged user
# You may want to change the UID and GID to match the ones on your host
# ------------------------------------------------------------------------------

ARG USER=andrei
ARG USERID=1001

RUN addgroup -g ${USERID} ${USER} && adduser -u ${USERID} -D -S -g ${USER} ${USER} 

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

# ------------------------------------------------------------------------------
# Create laravel project in /laravel, switch dir and run the development server
# on port 8000 (remember to expose this port with -p 8000:8000 or -P)
# ------------------------------------------------------------------------------

RUN composer create-project --prefer-dist laravel/laravel laravel

WORKDIR /home/${USER}/laravel

RUN php artisan make:auth

RUN npm install

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host", "0.0.0.0", "--port", "8000"]

# ------------------------------------------------------------------------------
# Run using
# 
# $ docker run -d -p 8000:8000 --name laravel andreicon/laravel
#
# To send commands (eg. migrate tables for the auth we made during build)
#
# $ docker exec laravel php artisan migrate
#
# ------------------------------------------------------------------------------
