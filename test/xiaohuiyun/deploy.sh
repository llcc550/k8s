#!/bin/bash
# 创建namespace
kubectl create namespace xiaohuiyun
kubectl create namespace mogodb

#部署mongodb
mkdir -p /data/nfs/mogodb
kubectl apply -f /data/code/config/test/xiaohuiyun/mongodb/mongodb.yaml
# 部署beanstalkd
kubectl apply -f /data/code/config/test/xiaohuiyun/yaml/beanstalkd.yaml

# 部署etcd
mkdir -p /data/nfs/etcd
kubectl apply -f /data/code/config/test/xiaohuiyun/yaml/etcd.yaml

# 配置文件
mkdir -p /data/nfs/conf && /bin/cp -rf /data/code/config/test/xiaohuiyun/golang-apps/conf/* /data/nfs/conf/
kubectl apply -f /data/code/config/test/xiaohuiyun/yaml/conf.yaml

# nfs文件权限
chown nfsnobody:nfsnobody -R /data/nfs

# endpoints: mysql
kubectl apply -f /data/code/config/test/xiaohuiyun/yaml/mysql.yaml
# endpoints: redis
kubectl apply -f /data/code/config/test/xiaohuiyun/yaml/redis.yaml

sed -i 's#/data/code/goworkspace/$serviceName#/data/code/goworkspace#g' `grep -rl '/data/code/goworkspace/$serviceName' ./* --exclude=deploy.sh`

serviceNames=(
socket-server
faceengine-rmq
sms-rpc
attachment-rpc
socketpush-rpc
reddot-rpc
tenant-rpc
organization-rpc
attachment-rpc
card-rpc
classes-rpc
user-rpc
acl-rpc
face-rpc
captcha-rpc
member-rpc
department-rpc
subject-rpc
pdf-rpc
studentparent-rpc
dorm-rpc
wechat-rpc
timetable-rpc
addressbook-rpc
apk-rpc
deviceposition-rpc
cloudscreenmodule-rpc
customboard-rpc
trip-rpc
vacation-rpc
acl-api
auth-api
captcha-api
classes-api
connection-api
department-api
dorm-api
face-api
face-rmq
member-api
module-api
organization-api
pdf-api
pdf-rmq
sms-rmq
socketpush-rmq
studentparent-api
subject-api
wechat-rmq
wechatpush-rmq
addressbook-api
afterschool-api
afterschool-cron
afterschool-rmq
afterschoolservice-api
afterschoolservice-cron
apk-api
attendancedorm-rmq
attendanceselfstudy-api
attendanceselfstudy-cron
attendanceselfstudy-rmq
award-api
classfeed-api
classnotice-api
cloudscreenmodule-api
cloudscreennotice-api
customboard-api
datacenter-cron
deviceposition-api
document-api
documentflow-api
emancipation-api
emancipation-cron
emancipation-rmq
exam-api
examresult-api
expression-api
homepage-api
homework-api
inventory-api
leave-api
letter-api
mailbox-api
medicalexamination-api
medicalexamination-cron
meeting-api
memberattribute-api
message-api
messageboard-api
openapi-api
organizationnotice-api
planduty-api
pneumonia-api
qinghu-cron
rating-api
recommendation-api
remark-api
repair-api
salary-api
stadium-api
studentattendance-api
teacherattendance-api
teacherattendance-cron
teacherattendance-rmq
timetable-api
timetable-cron
transfer-api
trip-api
trip-rmq
turnstile-api
turnstile-cron
turnstile-rmq
visitor-api
visitor-cron
visitor-rmq
zuy-api
zuy-cron
wisdomteaching-api
sanctumuser-api
)

for serviceName in ${serviceNames[@]}
do
  sh "/data/code/config/test/xiaohuiyun/golang-apps/k8s/$serviceName/$serviceName.sh"
done

# web
sh /data/code/config/test/xiaohuiyun/front-php-apps/web/web-init.sh
# web-api
sh /data/code/config/test/xiaohuiyun/front-php-apps/web-api/web-api-init.sh
# 班牌API
sh /data/code/config/test/xiaohuiyun/front-php-apps/board-api/board-api-init.sh
# web-h5
sh /data/code/config/test/xiaohuiyun/front-php-apps/web-h5/web-h5-init.sh
# 微信api
sh /data/code/config/test/xiaohuiyun/front-php-apps/wechat-web-api/wechat-web-api-init.sh
# 微信web
sh /data/code/config/test/xiaohuiyun/front-php-apps/wechat-web/wechat-web-init.sh
# 中控web
sh /data/code/config/test/xiaohuiyun/front-php-apps/sanctum-web/sanctum-web-init.sh

# 创建https证书
# kubectl create -n zaun secret tls tls-pem-w --key /data/code/config/doc/tls/wechat.u-jy.cn/wechat.u-jy.cn.key --cert /data/code/config/doc/tls/wechat.u-jy.cn/wechat.u-jy.cn.crt
# 创建ingress控制器
# kubectl apply -f /data/code/config/test/xiaohuiyun/ingress-nginx/ingress-nginx.yaml
# ingress规则生效
kubectl apply -f /data/code/config/test/xiaohuiyun/ingress-nginx/ingress-golang-api.yaml
kubectl apply -f /data/code/config/test/xiaohuiyun/ingress-nginx/ingress-php-web.yaml