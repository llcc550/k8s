#!/bin/sh

# 应用名称以及应用入口文件在源码中的路径
# 主入口所在目录 $goWorkspace/$servicePath
serviceName="device-api"
fileName="device.go"
servicePath="src/demacia/datacenter/device/api"

# k8s命名空间、私有镜像仓库地址
namespace="demacia"
imageRegistry="swr.cn-east-3.myhuaweicloud.com/demacia"

# 配置文件所在的目录
configFileDir="/data/code/config/test"

#----------------------------以下无需配置---------------------------------------------------

echo "----------------------------开始编译 $serviceName -----------------------------"

# 使用jenkins构建服务时，各服务使用独立的工作空间，以免同时构建时代码互相干扰
# 初始化时使用同一份代码build所有服务，先clone一份源码到/data/code/goworkspace/src/demacia，$goWorkspace通过sed修改为 "/data/code/goworkspace"。
goWorkspace="/data/code/goworkspace/demacia-$serviceName"

# 进入工作区
cd $goWorkspace/$servicePath

# 编译golang
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOARM=6 go build -a -trimpath -installsuffix cgo -ldflags="-s -w" -o demacia-$serviceName $fileName

if [ ! -d /data/code/config/build/demacia-$serviceName ];then
  mkdir -vp /data/code/config/build/demacia-$serviceName
fi
cd /data/code/config/build/demacia-$serviceName

# 移动打包生成的可执行文件
mv -f $goWorkspace/$servicePath/demacia-$serviceName app
# 复制配置文件
/bin/cp -f $configFileDir/demacia/golang-apps/config.yaml config.yaml

let fsM=`ls -l app|awk '{print $5}'`/1024000
echo "编译成功，大小 $fsM M"

echo "FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:alpine-3.14.2-amd64
COPY app app
COPY config.yaml config.yaml" > Dockerfile

nowImageVersion=`date +%Y%m%d%H%M%S`
docker build -t $imageRegistry/$serviceName:$nowImageVersion .
imageSize=`docker images | grep $nowImageVersion |awk '{print $NF}' | awk -F 'MB' '{print $1}'`
echo "镜像构建成功！镜像大小 $imageSize M"

echo "推送镜像到镜像中心"
docker push $imageRegistry/$serviceName:$nowImageVersion

echo "更新k8s的deployment.yaml文件，锁定最新镜像"
deploymentFile="$configFileDir/demacia/golang-apps/$serviceName/deployment.yaml"
imageVersion=`cat $deploymentFile | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$imageVersion/$nowImageVersion/g" $deploymentFile
kubectl apply -f $deploymentFile

echo "----------------------------k8s部署状态-----------------------------"
sleep 5
kubectl get pod -n $namespace -o wide | grep demacia-$serviceName
podStatus=`kubectl get pod -n $namespace | grep demacia-$serviceName  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------$serviceName: 更新失败-----------------------------"
else
  echo "----------------------------$serviceName: 更新成功-----------------------------"
fi