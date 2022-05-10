FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/openresty:1.19.9.1-alpine-apk-amd64
ADD . /www
WORKDIR /www
ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
RUN rm -f /www/nginx.conf