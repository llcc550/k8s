#!/bin/sh

# 容器镜像仓库地址、当前打包生成的镜像版本、k8s中当前服务所在的命名空间
imageRegistry=swr.cn-east-3.myhuaweicloud.com/xiaohuiyun
nowImageVersion=`date +%Y%m%d%H%M%S`
namespace="zaun"

echo "----------------------------training : 开始更新-----------------------------"

# 源代码根目录
sourceCodeDir="/data/code"
# 项目配置文件所在目录
configFileDir="$sourceCodeDir/config/test/zaun/training"
# 源代码所在目录
sourceCodeDir="$sourceCodeDir/training"

/bin/cp -rf $configFileDir/.env $sourceCodeDir/.env

cd $sourceCodeDir

docker run --rm -v "$(pwd)":/go/ -w /go swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.1.17-swoole-4.2.10-git-amd64 composer install --no-dev

echo "#!/bin/sh
php-fpm -D
openresty -g 'daemon off;'" > start.sh

echo "FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/php:7.2.34-openresty-1.19.9.1-amd64
ADD . /html
ADD start.sh ./start.sh
RUN chmod +x ./start.sh && chmod -R 777 /html
CMD  [\"./start.sh\"]" > Dockerfile

docker build --no-cache -t $imageRegistry/training:$nowImageVersion .
docker push $imageRegistry/training:$nowImageVersion

k8sConfigFile="$configFileDir/training-k8s.yaml"
oldImageVersion=`cat $k8sConfigFile | grep "image:" | awk -F ':' '{print $3}'`
sed -i "s/$oldImageVersion/$nowImageVersion/g" $k8sConfigFile

kubectl apply -f $configFileDir/training-pv.yaml
kubectl apply -f $configFileDir/training-pvc.yaml
kubectl apply -f $configFileDir/training-nginx-config.yaml
kubectl apply -f $configFileDir/training-php-config.yaml
kubectl apply -f $k8sConfigFile

echo "----------------------------k8s部署状态-----------------------------"
sleep 10
kubectl get pod -n $namespace -o wide | grep training
podStatus=`kubectl get pod -n $namespace | grep training | grep Running | awk '{print $1}' | head -n 1`
if [ ! $podStatus ] ; then
  echo "----------------------------training: 更新失败-----------------------------"
else
  echo "----------------------------training: 更新成功-----------------------------"
fi