# syntax=docker/dockerfile:1

#    # Build application front-end (you can drop this block at all if you want)
#    FROM public.ecr.aws/docker/library/node:18-alpine as frontend
#    # copy all application sources
#    COPY . /app/
#    # use directory with application sources by default
#    WORKDIR /app
#    # build frontend
#    RUN set -x \
#        && npm ci --no-audit --prefer-offline \
#        && NODE_ENV="production" npm run build

# fetch the RoadRunner image
FROM ghcr.io/roadrunner-server/roadrunner:2.12.3 as roadrunner

# fetch the Composer image
FROM public.ecr.aws/composer/composer:2.6 as composer

# build application runtime
FROM public.ecr.aws/docker/library/php:8.2-alpine as runtime

# install composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

ENV COMPOSER_HOME="/tmp/composer"

RUN set -x \
    # install permanent dependencies
    && apk add --no-cache \
        postgresql-libs \
        icu-libs \
    # install build-time dependencies
    && apk add --no-cache --virtual .build-deps \
        postgresql-dev \
        linux-headers \
        autoconf \
        openssl \
        make \
        g++ \
    # install PHP extensions (CFLAGS usage reason - https://bit.ly/3ALS5NU)
    && CFLAGS="$CFLAGS -D_GNU_SOURCE" docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        sockets \
        opcache \
        pcntl \
        intl \
        1>/dev/null \
    && pecl install -o redis 1>/dev/null \
    && echo 'extension=redis.so' > ${PHP_INI_DIR}/conf.d/redis.ini \
    # install supercronic (for laravel task scheduling), project page: <https://github.com/aptible/supercronic> \
    && apkArch="$(apk --print-arch)" \
    && case "$apkArch" in \
        armhf) _cronic_fname='supercronic-linux-arm' ;; \
        aarch64) _cronic_fname='supercronic-linux-arm64' ;; \
        x86_64) _cronic_fname='supercronic-linux-amd64' ;; \
        x86) _cronic_fname='supercronic-linux-386' ;; \
        *) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
    esac \
    && wget -O /usr/bin/supercronic "https://github.com/aptible/supercronic/releases/download/v0.2.2/${_cronic_fname}" \
    && chmod +x /usr/bin/supercronic \
    && mkdir /etc/supercronic \
    && echo '*/1 * * * * php /app/artisan schedule:run' > /etc/supercronic/laravel \
    # generate self-signed SSL key and certificate files
    && openssl req -x509 -nodes -days 1095 -newkey rsa:2048 \
        -subj "/C=CA/ST=QC/O=Company, Inc./CN=mydomain.com" \
        -addext "subjectAltName=DNS:mydomain.com" \
        -keyout /etc/ssl/private/selfsigned.key \
        -out /etc/ssl/certs/selfsigned.crt \
    && chmod 644 /etc/ssl/private/selfsigned.key \
    # make clean up
    && docker-php-source delete \
    && apk del .build-deps \
    && rm -R /tmp/pear \
    # enable opcache for CLI and JIT, docs: <https://www.php.net/manual/en/opcache.configuration.php#ini.opcache.jit>
    && echo -e "\nopcache.enable=1\nopcache.enable_cli=1\nopcache.jit_buffer_size=32M\nopcache.jit=1235\n" >> \
        ${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini \
    # show installed PHP modules
    && php -m \
    # create unprivileged user
    && adduser \
        --disabled-password \
        --shell "/sbin/nologin" \
        --home "/nonexistent" \
        --no-create-home \
        --uid "10001" \
        --gecos "" \
        "appuser" \
    # create directory for application sources and roadrunner unix socket
    && mkdir /app /var/run/rr \
    && chown -R appuser:appuser /app /var/run/rr \
    && chmod -R 777 /var/run/rr

# install roadrunner
COPY --from=roadrunner /usr/bin/rr /usr/bin/rr

# use an unprivileged user by default
USER appuser:appuser

# use directory with application sources by default
WORKDIR /app

# copy composer (json|lock) files for dependencies layer caching
COPY --chown=appuser:appuser ./composer.* /app/

# install composer dependencies (autoloader MUST be generated later!)
RUN composer install -n --no-dev --no-cache --no-ansi --no-autoloader --no-scripts --prefer-dist

# copy application sources into image (completely)
COPY --chown=appuser:appuser . /app/

#    # copy front-end artifacts into image
#    COPY --from=frontend --chown=appuser:appuser /app/public /app/public

RUN set -x \
    # generate composer autoloader and trigger scripts
    && composer dump-autoload -n --optimize \
    # "fix" composer issue "Cannot create cache directory /tmp/composer/cache/..." for docker-compose usage
    && chmod -R 777 ${COMPOSER_HOME}/cache \
    # create the symbolic links configured for the application
    && php ./artisan storage:link

# unset default image entrypoint
ENTRYPOINT []
