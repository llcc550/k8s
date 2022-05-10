#!/bin/sh

# 容器镜像仓库地址、当前打包生成的镜像版本、k8s中当前服务所在的命名空间
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun
nowImageVersion=`date +%Y%m%d%H%M%S`
namespace="xiaohuiyun"

# 源代码根目录
sourceCodeDirAll="/data/code"
# 项目配置文件所在目录
configFileDir="$sourceCodeDirAll/config/test/zaun/xy-homepage-web"
# 源代码所在目录
sourceCodeDir="$sourceCodeDirAll/xy-homepage-web/web"

#复制配置文件
/bin/cp -rf $configFileDir/.env $sourceCodeDir/.env

echo "----------------------------xy-homepage-web: 开始编译-----------------------------"
# 更新并编译
cd $sourceCodeDir  && yarn && yarn run build

if [ ! -d $configFileDir/build ];then
  mkdir -vp $configFileDir/build
fi

rm -rf $configFileDir/build/* && /bin/cp -r -a $sourceCodeDir/dist/* $configFileDir/build/
echo "----------------------------xy-homepage-web: 完成编译-----------------------------"


echo "----------------------------xy-homepage-web: 开始打包镜像-----------------------------"

# 在配置文件目录下打包build文件夹，并推送
cd $configFileDir
docker build --no-cache -t $imageRegistry/xy-homepage-web:$nowImageVersion .
docker push $imageRegistry/xy-homepage-web:$nowImageVersion

# 更新k8s的yaml文件为最新版本，并发布
k8sConfigFile="$configFileDir/xy-homepage-web-k8s.yaml"
oldImageVersion=`cat $k8sConfigFile | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$oldImageVersion/$nowImageVersion/g" $k8sConfigFile
kubectl apply -f $configFileDir/xy-homepage-web-nginx-config.yaml
kubectl apply -f $k8sConfigFile

# 验证服务状态
echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep xy-homepage-web
podStatus=`kubectl get pod -n $namespace | grep xy-homepage-web  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------xy-homepage-web: 更新失败-----------------------------"
else
  echo "----------------------------xy-homepage-web: 更新成功-----------------------------"
fi
