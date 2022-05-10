FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/openresty:1.19.9.1-alpine-apk-amd64
ADD ./build /www
ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
WORKDIR /www