# docker build -t swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-ffmpeg-amd64 .
#FROM debian:buster-slim@sha256:f6ed7ce6e3264649e1d4f40585247c50e32faaf268984c5c5cbf0e67cf7f0ec7

# docker build -t swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-arm64 .
FROM debian:buster-slim@sha256:9f6e6f1f5a4665a552f46028808b28ab19788d28db470de6822febf710f47914

COPY ImageMagick ImageMagick
COPY libwebp libwebp
COPY aom aom
COPY libheif.tar.gz libheif.tar.gz

RUN apt update -y \
    && apt upgrade -y \
    && apt-get -y update \
    && apt-get -y upgrade \
    && apt-get install -y git make gcc pkg-config autoconf curl g++ \
    yasm cmake \
    libde265-0 libde265-dev libjpeg62-turbo libjpeg62-turbo-dev x265 libx265-dev libtool \
    libpng16-16 libpng-dev libjpeg62-turbo libjpeg62-turbo-dev libgomp1 ghostscript libxml2-dev libxml2-utils libtiff-dev libfontconfig1-dev libfreetype6-dev \
    && cd libwebp  && ./autogen.sh && ./configure --enable-shared --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux --enable-static=no \
    && make && make install \
    && ldconfig /usr/local/lib \
    && cd ../ && rm -rf libwebp \
    && mkdir build_aom \
    && cd build_aom \
    && cmake ../aom/ -DENABLE_TESTS=0 -DBUILD_SHARED_LIBS=1 && make && make install \
    && ldconfig /usr/local/lib \
    && cd ../ \
    && rm -rf aom \
    && rm -rf build_aom \
    && tar -xzvf libheif.tar.gz && cd libheif-1.12.0/ && ./autogen.sh && ./configure && make && make install && cd .. \
    && ldconfig /usr/local/lib \
    && rm -rf libheif-1.12.0 && rm libheif.tar.gz \
    && cd ImageMagick && ./configure --without-magick-plus-plus --disable-docs --disable-static --with-libtiff \
    && make && make install \
    && ldconfig /usr/local/lib \
    && apt-get install ffmpeg -y \
    && apt-get remove --autoremove --purge -y gcc make cmake curl g++ yasm git autoconf pkg-config libpng-dev libjpeg62-turbo-dev libde265-dev libx265-dev libxml2-dev libtiff-dev libfontconfig1-dev libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /ImageMagick

ENTRYPOINT ["convert"]