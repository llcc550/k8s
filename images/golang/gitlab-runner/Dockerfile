# docker build -t swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:runner-base .
FROM golang:1.18.0

RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
    && rm -Rf /var/lib/apt/lists/* \
    && apt update -yq \
    && apt upgrade -yq \
    && apt-get update -yq \
    && apt-get install -yq locales make xz-utils zip libffi-dev jq wget git python gcc g++ curl tzdata ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://u-pro.obs.cn-east-3.myhuaweicloud.com/ImageMagick-7.1.0-1.tar.gz \
    && tar xvzf ImageMagick-7.1.0-1.tar.gz \
    && rm -f ImageMagick-7.1.0-1.tar.gz \
    && cd ImageMagick-7.1.0-1 \
    && ./configure \
    && make \
    && make install \
    && ldconfig /usr/local/lib \
    && echo "en_US UTF-8" > /etc/locale.gen; locale-gen en_US.UTF-8 \
    && go env -w GOSUMDB=off \
    && go env -w GOPROXY=https://goproxy.cn,direct \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN go install github.com/jstemmer/go-junit-report@latest && go install golang.org/x/lint/golint@latest

COPY libarcsoft_face.so /usr/lib64/libarcsoft_face.so
COPY libarcsoft_face_engine.so /usr/lib64/libarcsoft_face_engine.so