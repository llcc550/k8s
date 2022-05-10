# docker build -t swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-openresty-1.19.9.1-ps-ffmpeg-amd64 .
FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-ffmpeg-amd64

# docker build -t swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-openresty-1.19.9.1-ps-ffmpeg-arm64 .
#FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-arm64

RUN apt-get -y update && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends wget vim cron procps gnupg ca-certificates \
    && wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - \
    && echo "deb http://openresty.org/package/debian buster openresty" > /etc/apt/sources.list.d/openresty.list \
    && apt-get -y update && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends openresty \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone