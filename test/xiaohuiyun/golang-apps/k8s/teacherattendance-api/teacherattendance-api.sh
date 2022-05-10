#!/bin/sh

# 应用名称以及应用入口文件在源码中的路径
# 主入口所在目录 $goWorkspace/$servicePath
serviceName="teacherattendance-api"
fileName="teacherattendance.go"
servicePath="src/epoch/app/ujy/module/teacherattendance/cmd/api"

# 初始化时可以使用一套代码编译,各服务可以使同一工作空间。测试、生产环境，各服务使用独立的工作空间。初始化时GoWorkspace需修改为 "/data/code/goworkspace"
goWorkspace="/data/code/goworkspace/$serviceName"

# 复制应用配置文件
/bin/cp -f /data/code/config/test/xiaohuiyun/golang-apps/conf/$serviceName.yaml /data/nfs/conf/$serviceName.yaml

# 配置文件所在目录
configFileDir="/data/code/config/test/xiaohuiyun/golang-apps/k8s/$serviceName"

# k8s命名空间、私有镜像仓库地址
namespace="xiaohuiyun"
imageRegistry="swr.cn-east-3.myhuaweicloud.com/xiaohuiyun"

#----------------------------以下无需配置---------------------------------------------------

echo "----------------------------开始编译 $serviceName -----------------------------"

# 进入工作区
cd $goWorkspace/$servicePath

# 编译golang
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOARM=6 go build -a -trimpath -installsuffix cgo -ldflags="-s -w" -o $serviceName $fileName

cd /data/code/config/build

mv $goWorkspace/$servicePath/$serviceName $serviceName
let fsM=`ls -l $serviceName|awk '{print $5}'`/1024000
echo "编译成功，大小 $fsM M"

echo "打包镜像"

echo "FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/golang:alpine-3.14.2-amd64
WORKDIR /app
COPY $serviceName /app/" > Dockerfile

nowImageVersion=`date +%Y%m%d%H%M%S`
docker build -t $imageRegistry/$serviceName:$nowImageVersion .
imageSize=`docker images | grep $nowImageVersion |awk '{print $NF}' | awk -F 'MB' '{print $1}'`
echo "镜像构建成功！镜像大小 $imageSize M"

echo "推送镜像到镜像中心"
docker push $imageRegistry/$serviceName:$nowImageVersion

echo "更新k8s的yml文件，锁定最新镜像"
k8sConfigFile="$configFileDir/k8s-$serviceName.yaml"
imageVersion=`cat $k8sConfigFile | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$imageVersion/$nowImageVersion/g" $k8sConfigFile
kubectl apply -f $k8sConfigFile

echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep $serviceName
podStatus=`kubectl get pod -n $namespace | grep $serviceName  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------$serviceName: 更新失败-----------------------------"
else
  echo "----------------------------$serviceName: 更新成功-----------------------------"
fi
rm -f $serviceName
rm -f Dockerfile