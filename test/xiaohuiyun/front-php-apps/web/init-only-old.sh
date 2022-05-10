#!/bin/sh

# 容器镜像仓库地址
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun
# k8s中当前服务所在的命名空间
namespace="xiaohuiyun"
# 项目配置文件所在目录
configFileDir="/data/code/config/test/xiaohuiyun/front-php-apps/web"
# 老web源代码所在目录
webSourceCodeDir="/data/code/web"
# 新web源代码所在目录
webNewSourceCodeDir="/data/code/web-new"

echo "----------------------------web: 开始更新-----------------------------"

# web项目由老web和新web组合而成
# 老web是php混编项目，只需pull最新代码即可
# 新web是vue项目，需将编译后的前端代码复制到老web的v2目录下

# 当前打包生成的镜像版本
nowImageVersion=`date +%Y%m%d%H%M%S`

#复制lua脚本
/bin/cp -rf $configFileDir/lua $webSourceCodeDir/lua

#复制新web配置文件
/bin/cp -rf $configFileDir/.env $webNewSourceCodeDir/.env

#复制老web配置文件
/bin/cp -rf $configFileDir/env.js $webSourceCodeDir/env.js
/bin/cp -rf $configFileDir/http_url.js $webSourceCodeDir/http_url.js
/bin/cp -rf $configFileDir/config.php $webSourceCodeDir/application/config/config.php
/bin/cp -rf $configFileDir/config.php $webSourceCodeDir/mp_application/config/config.php
/bin/cp -rf $configFileDir/config.php $webSourceCodeDir/sanctum_application/config/config.php
/bin/cp -rf $configFileDir/database.php $webSourceCodeDir/application/config/database.php
/bin/cp -rf $configFileDir/database.php $webSourceCodeDir/mp_application/config/database.php
/bin/cp -rf $configFileDir/database.php $webSourceCodeDir/sanctum_application/config/database.php

#复制nginx.conf和php.ini
/bin/cp -rf $configFileDir/nginx.conf $webSourceCodeDir/nginx.conf
/bin/cp -rf $configFileDir/php.ini $webSourceCodeDir/php.ini

# 如果v2不存在，还是需要编译一下新web
if [ ! -d $webSourceCodeDir/v2 ];then
  mkdir -vp $webSourceCodeDir/v2
  # 更新并编译新web项目
  cd $webNewSourceCodeDir  && yarn && yarn run build
  rm -rf $webSourceCodeDir/v2/* && /bin/cp -r -a $webNewSourceCodeDir/dist/* $webSourceCodeDir/v2/
fi

# 更新老web
cd $webSourceCodeDir
# 初始化老web临时文件上传目录
if [ ! -d $webSourceCodeDir/uploads/import ];then
  mkdir -vp $webSourceCodeDir/uploads/import
fi

# 写入php+nginx服务启动脚本
echo "#!/bin/sh
php-fpm -D
openresty -g 'daemon off;'" > start.sh

# 在老web项目下打包，并推送
echo "FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.2.34-openresty-1.19.9.1-amd64-0.1
ADD . /html
ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD php.ini /usr/local/etc/php/php.ini
ADD start.sh ./start.sh
ADD ./lua/* /usr/local/openresty/lua/
RUN chmod +x ./start.sh && chmod -R 777 /html/uploads && chmod -R 777 /html/application/logs && rm -f /html/nginx.conf /html/php.ini && rm -rf /html/lua
CMD  [\"./start.sh\"]" > Dockerfile

docker build --no-cache -t $imageRegistry/web:$nowImageVersion .
docker push $imageRegistry/web:$nowImageVersion

# 更新k8s的yaml文件为最新版本，并发布
deploymentYaml="$configFileDir/deployment.yaml"
oldImageVersion=`cat $deploymentYaml | grep "web:" | awk -F ':' '{print $3}'`
sed -i "s/$oldImageVersion/$nowImageVersion/g" $deploymentYaml
kubectl apply -f $deploymentYaml

# hpa策略
kubectl apply -f $configFileDir/hpa.yaml

# 验证服务状态
sleep 30
echo "----------------------------k8s部署状态-----------------------------"
kubectl get pod -n $namespace -o wide | grep web | grep -vE 'api|h5|wechat|sanctum|xy-homepage'
podStatus=`kubectl get pod -n $namespace | grep web | grep -vE 'api|h5|wechat|sanctum|xy-homepage'  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------web: 更新失败-----------------------------"
else
  echo "----------------------------web: 更新成功-----------------------------"
fi