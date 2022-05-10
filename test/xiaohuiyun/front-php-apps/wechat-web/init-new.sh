#!/bin/sh

# 容器镜像仓库地址
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun

# 项目配置文件所在目录
configFileDir="/data/code/config/test/xiaohuiyun/front-php-apps/wechat-web"
# 老微信web源代码所在目录
wechatOldSourceCodeDir="/data/code/wechat-web"
# 新微信web源代码所在目录
wechatNewSourceCodeDir="/data/code/wechat-web-new"

echo "----------------------------wechat-web: 开始更新-----------------------------"
# wechat-web项目由老微信web和新微信web组合而成，都需使用编译后的前端代码
# 老微信web的执行代码需放在wechat-web下
# 新微信web的执行代码需放在allin下

# k8s中当前服务所在的命名空间
namespace="xiaohuiyun"

# 当前打包生成的镜像版本
nowImageVersion=`date +%Y%m%d%H%M%S`

#复制老微信web配置文件
/bin/cp -rf $configFileDir/prod.env.js $wechatOldSourceCodeDir/config/prod.env.js
#复制新微信web配置文件
/bin/cp -rf $configFileDir/.env $wechatNewSourceCodeDir/.env

if [ ! -d $configFileDir/build/wechat-web ];then
  echo "----------------------------wechat-web: 老微信尚未编译，同时更新-----------------------------"
  mkdir -vp $configFileDir/build/wechat-web
  # 更新并编译老微信web项目
  cd $wechatOldSourceCodeDir  && yarn && yarn run build
  rm -rf $configFileDir/build/wechat-web/* && /bin/cp -r -a $wechatOldSourceCodeDir/dist/* $configFileDir/build/wechat-web/
  echo "----------------------------wechat-web: 老微信完成编译-----------------------------"
fi

echo "----------------------------wechat-web: 新微信开始编译-----------------------------"
# 更新并编译新微信web项目
cd $wechatNewSourceCodeDir  && yarn && yarn run build
if [ ! -d $configFileDir/build/allin ];then
  mkdir -vp $configFileDir/build/allin
fi
rm -rf $configFileDir/build/allin/* && /bin/cp -r -a $wechatNewSourceCodeDir/build/* $configFileDir/build/allin/
echo "----------------------------wechat-web: 新微信完成编译-----------------------------"

echo "----------------------------wechat-web: 开始打包镜像-----------------------------"
# 在配置文件目录下打包build文件夹，并推送
cd $configFileDir/build
docker build --no-cache -t $imageRegistry/wechat-web:$nowImageVersion .
docker push $imageRegistry/wechat-web:$nowImageVersion

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
kubectl get pod -n $namespace -o wide | grep wechat-web
podStatus=`kubectl get pod -n $namespace | grep wechat-web  | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------wechat-web: 更新失败-----------------------------"
else
  echo "----------------------------wechat-web: 更新成功-----------------------------"
fi
