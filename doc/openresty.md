## centos7安装openresty

```shell
wget --no-check-certificate -c https://openresty.org/package/centos/openresty.repo -O /etc/yum.repos.d/openresty.repo
yum install -y openresty
systemctl enable openresty
# 默认配置文件 /usr/local/openresty/nginx/conf/nginx.conf
openresty
```