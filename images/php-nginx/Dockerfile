FROM php:7.2-fpm-alpine3.12
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && wget https://openresty.org/package/admin@openresty.com-5ea678a6.rsa.pub -O /etc/apk/keys/admin@openresty.com-5ea678a6.rsa.pub \
    && echo "https://openresty.org/package/alpine/v3.12/main" >> /etc/apk/repositories \
    && apk update \
    && apk add openresty=1.19.9.1-r0 m4 autoconf make gcc g++ linux-headers tzdata libxml2-dev libzip-dev \
    && apk add --no-cache --virtual .build-deps libxml2-dev \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install pdo_mysql opcache mysqli soap \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del m4 autoconf make gcc g++ linux-headers tzdata \
    && mkdir -p /var/run/openresty