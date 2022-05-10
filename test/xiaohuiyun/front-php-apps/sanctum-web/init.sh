#!/bin/sh

# 容器镜像仓库地址
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun

# 项目配置文件所在目录
configFileDir="/data/code/config/test/xiaohuiyun/front-php-apps/sanctum-web"
# 源代码所在目录
sourceCodeDir="/data/code/sanctum-web"

echo "----------------------------sanctum-web: 开始更新-----------------------------"

# k8s中当前服务所在的命名空间
namespace="xiaohuiyun"

# 当前打包生成的镜像版本
nowImageVersion=`date +%Y%m%d%H%M%S`

# 复制配置文件
/bin/cp -rf $configFileDir/.env $sourceCodeDir/.env

cd $sourceCodeDir
yarn && yarn run build

if [ ! -d $configFileDir/build ];then
  mkdir -vp $configFileDir/build
fi

rm -rf $configFileDir/build/* && /bin/cp -r -a $sourceCodeDir/dist/* $configFileDir/build/

cd $configFileDir
docker build --no-cache -t $imageRegistry/sanctum-web:$nowImageVersion .
docker push $imageRegistry/sanctum-web:$nowImageVersion

# 更新k8s的yaml文件为最新版本，并发布
deploymentYaml="$configFileDir/deployment.yaml"
oldImageVersion=`cat $deploymentYaml | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$oldImageVersion/$nowImageVersion/g" $deploymentYaml
kubectl apply -f $deploymentYaml

# hpa策略
kubectl apply -f $configFileDir/hpa.yaml

echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep sanctum-web
podStatus=`kubectl get pod -n $namespace | grep sanctum-web  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------sanctum-web: 更新失败-----------------------------"
else
  echo "----------------------------sanctum-web: 更新成功-----------------------------"
fi