# Geef de gewenste PHP-versie en Debian-versie op als build-argumenten
ARG PHP_VERSION
ARG VARIANT
ARG DEBIAN_VERSION

# Gebruik de opgegeven PHP-versie en Debian-versie in de FROM-regel
FROM php:${PHP_VERSION}-${VARIANT}-${DEBIAN_VERSION}

# Installeer vereiste pakketten
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        busybox-static \
        bzip2 \
        libldap-common \
        libmagickcore-6.q16-6-extra \
        rsync \
    ; \
    rm -rf /var/lib/apt/lists/*

# Stel PHP-omgevingsvariabelen in
ENV PHP_MEMORY_LIMIT 512M
ENV PHP_UPLOAD_LIMIT 512M

# Installeer PHP-extensies
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libevent-dev \
        libfreetype6-dev \
        libgmp-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libwebp-dev \
        libxml2-dev \
        libzip-dev \
    ; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-configure ldap --with-libdir="lib/x86_64-linux-gnu"; \
    docker-php-ext-install -j "$(nproc)" \
        bcmath \
        exif \
        gd \
        gmp \
        intl \
        ldap \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        sysvsem \
        zip \
    ; \
    \
    pecl install APCu imagick memcached redis; \
    docker-php-ext-enable \
        apcu \
        imagick \
        memcached \
        redis; \
    rm -r /tmp/pear; \
    \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Stel aanbevolen PHP.ini-instellingen in
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.interned_strings_buffer=32'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.jit=1255'; \
        echo 'opcache.jit_buffer_size=128M'; \
    } > "${PHP_INI_DIR}/conf.d/opcache-recommended.ini"; \
    \
    echo 'apc.enable_cli=1' >> "${PHP_INI_DIR}/conf.d/docker-php-ext-apcu.ini"; \
    \
    { \
        echo 'memory_limit=${PHP_MEMORY_LIMIT}'; \
        echo 'upload_max_filesize=${PHP_UPLOAD_LIMIT}'; \
        echo 'post_max_size=${PHP_UPLOAD_LIMIT}'; \
    } > "${PHP_INI_DIR}/conf.d/nextcloud.ini"; 

# Maak een volume voor Nextcloud-gegevens
VOLUME /var/www/html

# Stel de Nextcloud-versie in
ENV NEXTCLOUD_VERSION 10.0.0

# Voer deze container uit wanneer gestart
CMD ["php", "-S", "0.0.0.0:8081", "-t", "/var/www/html"]