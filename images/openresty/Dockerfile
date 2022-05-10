FROM openresty/openresty:1.19.9.1-alpine-apk@sha256:a5ac3af233e36b00eced6c4e373301396026b8e6f1ba36cee66d8900a4bb8e02

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata