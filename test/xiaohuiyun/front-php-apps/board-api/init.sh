#!/bin/sh

# 容器镜像仓库地址
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun

# 项目配置文件所在目录
configFileDir="/data/code/config/test/xiaohuiyun/front-php-apps/board-api"
# 源代码所在目录
sourceCodeDir="/data/code/board-api"

echo "----------------------------board-api : 开始更新-----------------------------"

# 当前打包生成的镜像版本
nowImageVersion=`date +%Y%m%d%H%M%S`
# k8s中当前服务所在的命名空间
namespace="xiaohuiyun"

# 复制配置文件
/bin/cp -rf $configFileDir/config.php $sourceCodeDir/api_application/config/config.php
/bin/cp -rf $configFileDir/database.php $sourceCodeDir/api_application/config/database.php

#复制nginx.conf和php.ini
/bin/cp -rf $configFileDir/nginx.conf $sourceCodeDir/nginx.conf
/bin/cp -rf $configFileDir/php.ini $sourceCodeDir/php.ini
# 复制lua脚本
/bin/cp -rf $configFileDir/lua $sourceCodeDir/lua

cd $sourceCodeDir

echo "#!/bin/sh
php-fpm -D
openresty -g 'daemon off;'" > start.sh

echo "FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.2.34-openresty-1.19.9.1-amd64
ADD . /html
ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD php.ini /usr/local/etc/php/php.ini
ADD start.sh ./start.sh
ADD ./lua/* /usr/local/openresty/lua/
RUN chmod +x ./start.sh && chmod -R 777 /html/api_application/logs && rm -f /html/nginx.conf /html/php.ini && rm -rf /html/lua
RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log
CMD  [\"./start.sh\"]" > Dockerfile

docker build --no-cache -t $imageRegistry/board-api:$nowImageVersion .
docker push $imageRegistry/board-api:$nowImageVersion

# 更新k8s的yaml文件为最新版本，并发布
deploymentYaml="$configFileDir/deployment.yaml"
oldImageVersion=`cat $deploymentYaml | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$oldImageVersion/$nowImageVersion/g" $deploymentYaml
kubectl apply -f $deploymentYaml

# hpa策略
kubectl apply -f $configFileDir/hpa.yaml

echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep board-api | grep -v custom | grep -v message
podStatus=`kubectl get pod -n $namespace | grep board-api | grep -v custom | grep -v message | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------board-api: 更新失败-----------------------------"
else
  echo "----------------------------board-api: 更新成功-----------------------------"
fi