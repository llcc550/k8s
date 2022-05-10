# 基础镜像

> arm架构的镜像尚未完全验证可行

#### 基础服务所需镜像

|            |                                                                                                                                                                                   |
|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| beanstalkd | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/beanstalkd:1.10-amd64<br/>swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/beanstalkd:1.12-arm64                             |
| etcd       | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/etcd:v3.5.0-amd64<br/>swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/etcd:v3.5.0-arm64                                     |
| redis      | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/redis:6.0.1-alpine-amd64<br/>swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/redis:6.2.5-alpine-arm64                       |
| openresty  | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/openresty:1.19.9.1-alpine-apk-amd64<br/>swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/openresty:1.19.9.1-alpine-apk-arm64 |

#### 应用运行时所需镜像

|                    |                                                                                                                                                                             |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| socket长链接          | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/socket-server:v2.4                                                                                                       |
| faceengine         | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/faceengine-rmq:v2.1-amd64                                                                                                |
| 普通应用               | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:alpine-3.14.2-amd64<br>swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:alpine-3.14.2-arm64              |
| pdf相关应用            | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-ffmpeg-amd64                                                                                  |
| web和board-api      | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.2.34-openresty-1.19.9.1-amd64<br/>swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.2.34-nginx-1.18.0-arm64 |
| web-api和wechat-api | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.1.17-swoole-4.2.10-amd64                                                                                           |

#### 应用打包时所需镜像

|                    |                                                                                                                                                                                                                |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pdf相关应用            | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:golang-1.17.2-imagemagick-7.1.0-1-ffmpeg-amd64<br/>swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:golang-1.17.2-imagemagick-7.1.0-1-arm64 |
| 独立部署golang-api一体服务 | swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:imagemagick-7.1.0-1-openresty-1.19.9.1-ps-ffmpeg-amd64                                                                                               |