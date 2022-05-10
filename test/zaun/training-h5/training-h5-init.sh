#!/bin/sh

# 镜像仓库地址
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun
nowImageVersion=`date +%Y%m%d%H%M%S`
namespace="zaun"

echo "----------------------------training-h5: 开始更新-----------------------------"

# 源代码根目录
sourceCodeDir="/data/code"
# 项目配置文件所在目录
configFileDir="$sourceCodeDir/config/test/zaun/training-h5"
# 源代码所在目录
sourceCodeDir="$sourceCodeDir/training-h5"

/bin/cp -rf $configFileDir/.env $sourceCodeDir/.env

cd $sourceCodeDir
yarn && yarn run build

if [ ! -d $configFileDir/build ];then
  mkdir -vp $configFileDir/build
fi

rm -rf $configFileDir/build/* && /bin/cp -r -a $sourceCodeDir/dist/* $configFileDir/build/

cd $configFileDir
docker build --no-cache -t $imageRegistry/training-h5:$nowImageVersion .
docker push $imageRegistry/training-h5:$nowImageVersion

k8sConfigFile="$configFileDir/training-h5-k8s.yaml"
oldImageVersion=`cat $k8sConfigFile | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$oldImageVersion/$nowImageVersion/g" $k8sConfigFile

kubectl apply -f $configFileDir/training-h5-nginx-config.yaml
kubectl apply -f $k8sConfigFile

echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep training-h5
podStatus=`kubectl get pod -n $namespace | grep training-h5  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------training-h5: 更新失败-----------------------------"
else
  echo "----------------------------training-h5: 更新成功-----------------------------"
fi