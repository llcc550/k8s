#!/bin/sh

# 容器镜像仓库地址、当前打包生成的镜像版本、k8s中当前服务所在的命名空间
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun
nowImageVersion=`date +%Y%m%d%H%M%S`
namespace="xiaohuiyun"

echo "----------------------------web-h5: 开始更新-----------------------------"

# 源代码根目录
sourceCodeDir="/data/code"
# 项目配置文件所在目录
configFileDir="$sourceCodeDir/config/xiaohuiyun-test/front-php-apps/web-h5"
# 源代码所在目录
sourceCodeDir="$sourceCodeDir/web-h5"

cd $sourceCodeDir

for dirName in $sourceCodeDir/*
do
    if test -d $dirName;then
      h5Model=$(basename $dirName)

      echo "----------------------------web-h5: $h5Model 开始更新-----------------------------"

      cd $sourceCodeDir/$h5Model

      /bin/cp -rf $configFileDir/env/$h5Model.env .env

      yarn && yarn run build

      if [ ! -d $configFileDir/build/$h5Model ];then
        mkdir -vp $configFileDir/build/$h5Model
      fi

      rm -rf $configFileDir/build/$h5Model/* && /bin/cp -r -a $sourceCodeDir/$h5Model/dist/* $configFileDir/build/$h5Model

      echo "----------------------------web-h5: $h5Model 完成更新-----------------------------"
    fi
done

echo "----------------------------web-h5: 开始打包-----------------------------"

cd $configFileDir
docker build --no-cache -t $imageRegistry/web-h5:$nowImageVersion .
docker push $imageRegistry/web-h5:$nowImageVersion

# 更新k8s的yaml文件为最新版本，并发布
k8sConfigFile="$configFileDir/web-h5-k8s.yaml"
oldImageVersion=$(cat $k8sConfigFile | grep "image:" | awk -F ':' '{print $3}')
sed -i "s/$oldImageVersion/$nowImageVersion/g" $k8sConfigFile
kubectl apply -f $configFileDir/web-h5-nginx-config.yaml
kubectl apply -f $k8sConfigFile

# 验证服务状态
echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep web-h5
podStatus=`kubectl get pod -n $namespace | grep web-h5  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------web-h5: 更新失败-----------------------------"
else
  echo "----------------------------web-h5: 更新成功-----------------------------"
fi