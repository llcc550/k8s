#FROM golang:1.17.2@sha256:f9292045d12e5935e9364949adc4ea00f700eb2f775058dc0bb6cc2dd04ab315
FROM golang:1.17.2@sha256:6d42b025238a0f98bf1c70e4630b114bd4a25427be52eb6889e7a779a9e344b4

COPY ImageMagick-7.1.0-1.tar.gz ./

RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
    && rm -Rf /var/lib/apt/lists/* \
    && apt update -yq \
    && apt upgrade -yq \
    && apt-get update -yq \
    && apt-get install -yq locales make xz-utils zip libffi-dev jq wget git python gcc g++ curl tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && tar xvzf ImageMagick-7.1.0-1.tar.gz \
    && cd ImageMagick-7.1.0-1 \
    && ./configure \
    && make \
    && make install \
    && ldconfig /usr/local/lib \
    && echo "en_US UTF-8" > /etc/locale.gen; locale-gen en_US.UTF-8 \
    && go env -w GOSUMDB=off \
    && go env -w GOPROXY=https://goproxy.cn,direct \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apt-get install ffmpeg -y

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/
ENV MAGICK_CODER_MODULE_PATH=/go/ImageMagick-7.1.0-1/coders/
ENV CGO_CFLAGS_ALLOW='-Xpreprocessor'