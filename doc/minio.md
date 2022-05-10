## centos7安装MINIO

1. 创建minio工作目录

```shell
mkdir -p /data/minio/data && cd /data/minio/
```

2. 下载可执行文件并添加权限

```shell
wget -c https://cdn.u-jy.cn/sourceFile/2021/08/_swrtYkzaGn -O minio
chmod +x minio
```

3. 创建minio用户和密码

```shell
export MINIO_ROOT_USER=minio-user
export MINIO_ROOT_PASSWORD=minio-user-pass
```

4. 启动minio服务

```shell
nohup /data/minio/minio server /data/minio/data  --address "0.0.0.0:30001" --console-address "0.0.0.0:30000" > /data/minio/minio.log 2>&1 &
# 30001为api端口，30000为webUI端口，若端口冲突可自行修改
```

5. 开机自启

```shell
cat <<EOF > /root/init-service.sh
export MINIO_ROOT_USER=minio-user
export MINIO_ROOT_PASSWORD=minio-user-pass
nohup /data/minio/minio server /data/minio/data  --address "0.0.0.0:30001" --console-address "0.0.0.0:30000" > /data/minio/minio.log 2>&1 &
EOF

echo "/root/init-service.sh " >> /etc/rc.d/rc.local
chmod +x /root/init-service.sh
chmod +x /etc/rc.d/rc.local
```

6. openresty做反向代理-可选

```shell
wget --no-check-certificate -c https://openresty.org/package/centos/openresty.repo -O /etc/yum.repos.d/openresty.repo
yum install -y openresty
systemctl enable openresty

# 域名，80或443、允许跨域、nginx调优
# 以上配置根据实际需求自行修改，端口、域名、证书等
cat <<EOF > /usr/local/openresty/nginx/conf/nginx.conf
worker_processes auto;
events {
    use epoll;
    worker_connections 65535;
}
http {
    include mime.types;
    default_type application/octet-stream;
    server_tokens off;
    sendfile on;
    keepalive_timeout 60;
    client_body_buffer_size 0;
    client_max_body_size 0;

    server {
        listen 80;
        listen 443 ssl;
        ssl_certificate   /data/ssl/tls.crt;
        ssl_certificate_key  /data/ssl/tls.key;
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        server_name minio.u-jy.cn;
        location / {
            more_set_headers "Access-Control-Allow-Origin:*";
            more_set_headers "Access-Control-Allow-Methods:GET, POST, OPTIONS, DELETE, PUT, PATCH";
            more_set_headers "Access-Control-Allow-Credentials:true";
            more_set_headers "Access-Control-Allow-Headers:ujy-session,User-Agent,Keep-Alive,Content-Type,Origin,Accept,Authorization,X-HTTP-Method-Override";
            proxy_set_header Host $http_host;
            proxy_pass http://localhost:30001;
        }
    }
    
    server {
        listen 80;
        listen 443 ssl;
        ssl_certificate   /data/ssl/tls.crt;
        ssl_certificate_key  /data/ssl/tls.key;
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        server_name minio-web.u-jy.cn;
        location / {
            proxy_set_header Host $http_host;
            proxy_pass http://localhost:30000;
        }
    }
}
EOF
# 启动openresty服务
openresty
```