# docker build -t swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.1.17-swoole-4.2.10-arm64 .
FROM alpine:3.6@sha256:66790a2b79e1ea3e1dabac43990c54aca5d1ddf268d9a5a0285e4167c8b24475

ARG timezone
ARG app_env=prod
ARG add_user=www-data
ENV APP_ENV=${app_env:-"prod"} \
    TIMEZONE=${timezone:-"Asia/Shanghai"} \
    SWOOLE_VERSION=4.2.10 \
    PHPIZE_DEPS="autoconf dpkg-dev dpkg file g++ gcc libc-dev make php7-dev php7-pear pkgconf re2c pcre-dev zlib-dev"
COPY swoole-src-4.2.10.tar.gz /tmp/swoole.tar.gz
RUN set -ex \
        && apk update \
        && apk add --no-cache \
        ca-certificates \
        curl \
        tar \
        xz \
        libressl \
        tzdata \
        pcre \
        php7 \
        php7-bcmath \
        php7-curl \
        php7-ctype \
        php7-dom \
        php7-fileinfo \
        php7-gd \
        php7-iconv \
        php7-json \
        php7-mbstring \
        php7-mysqlnd \
        php7-openssl \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_sqlite \
        php7-phar \
        php7-posix \
        php7-redis \
        php7-simplexml \
        php7-sockets \
        php7-sysvshm \
        php7-sysvmsg \
        php7-sysvsem \
        php7-tokenizer \
        php7-zip \
        php7-zlib \
        php7-xml \
        && cd /etc/php7 \
        && { \
            echo "upload_max_filesize=100M"; \
            echo "post_max_size=108M"; \
            echo "memory_limit=1024M"; \
            echo "date.timezone=${TIMEZONE}"; \
        } | tee conf.d/99-overrides.ini \
        && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
        && echo "${TIMEZONE}" > /etc/timezone \
        && addgroup -g 82 -S ${add_user} \
        && adduser -u 82 -D -S -G ${add_user} ${add_user} \
        && mkdir -p /data \
        && chown -R ${add_user}:${add_user} /data \
        && apk add --no-cache libstdc++ openssl \
        && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS libaio-dev openssl-dev \
        && cd /tmp \
        && mkdir -p swoole \
        && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
        && rm swoole.tar.gz \
        && ( \
            cd swoole \
            && phpize \
            && ./configure --enable-mysqlnd --enable-openssl \
            && make -j$(nproc) && make install \
        ) \
        && rm -r swoole \
        && echo "extension=swoole.so" > /etc/php7/conf.d/20_swoole.ini \
        && apk del --purge *-dev .build-deps \
        && rm -rf /var/cache/apk/* /tmp/* /usr/share/man /usr/share/php7 \
        && curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
        && chmod +x /usr/bin/composer \
        && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer