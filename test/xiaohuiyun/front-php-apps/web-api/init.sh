#!/bin/sh

# 容器镜像仓库地址
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun

# 项目配置文件所在目录
configFileDir="/data/code/config/test/xiaohuiyun/front-php-apps/web-api"
# 源代码所在目录
sourceCodeDir="/data/code/web-api"

echo "----------------------------web-api: 开始更新-----------------------------"

# k8s中当前服务所在的命名空间
namespace="xiaohuiyun"

# 当前打包生成的镜像版本
nowImageVersion=`date +%Y%m%d%H%M%S`

#复制配置文件
/bin/cp -rf $configFileDir/Conf/* $sourceCodeDir/Conf

#进入源代码目录，编译
cd $sourceCodeDir
rm -f composer.lock
rm -rf vendor
docker run --rm -v "$(pwd)":/go/ -w /go swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.1.17-swoole-4.2.10-amd64 composer install

# 打包docker镜像并推送到远程仓库
echo "FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.1.17-swoole-4.2.10-amd64
EXPOSE 9501
WORKDIR /web-api
COPY . /web-api
CMD [\"php\", \"easyswoole\",\"start\"]" > Dockerfile
docker build -t $imageRegistry/web-api:$nowImageVersion .
docker push $imageRegistry/web-api:$nowImageVersion

# 更新k8s的yaml文件为最新版本，并发布
deploymentYaml="$configFileDir/deployment.yaml"
oldImageVersion=`cat $deploymentYaml | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$oldImageVersion/$nowImageVersion/g" $deploymentYaml
kubectl apply -f $deploymentYaml

# hpa策略
kubectl apply -f $configFileDir/hpa.yaml

# 验证服务状态
echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep web-api
podStatus=`kubectl get pod -n $namespace | grep web-api  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------web-api: 更新失败-----------------------------"
else
  echo "----------------------------web-api: 更新成功-----------------------------"
fi