FROM centos:7
# FROM centos:7@sha256:864a7acea4a5e8fa7a4d83720fbcbadbe38b183f46f3600e04a3f8c1d961ed87

COPY ImageMagick-7.1.0-1.tar.gz ./

RUN yum update -y
RUN yum install -y nginx wget gcc automake autoconf libtool make libjpeg* libpng* freetype* gd*

RUN tar xvzf ImageMagick-7.1.0-1.tar.gz \
    && cd ImageMagick-7.1.0-1 \
    && ./configure --disable-dependency-tracking \
    && make \
    && make install \
    && ldconfig /usr/local/lib

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/
ENV MAGICK_CODER_MODULE_PATH=/ImageMagick-7.1.0-1/coders/
ENV CGO_CFLAGS_ALLOW='-Xpreprocessor'