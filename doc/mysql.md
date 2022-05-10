## centos7 安装mysql

### 1. 创建用户、数据目录

```shell
groupadd mysql
useradd -r -g mysql mysql
mkdir -p /data/mysql/data
chown mysql:mysql -R /data/mysql

```

### 2. 下载mysql安装文件和初始化表结构的sql

```shell
cd /data/mysql
wget https://u-bak.obs.cn-east-3.myhuaweicloud.com:443/deploy/ujy_demo.sql
wget https://cdn.u-jy.cn/mysql-5.7.32-el7-x86_64.tar.gz
tar -xvf mysql-5.7.32-el7-x86_64.tar.gz
mv mysql-5.7.32-el7-x86_64 /usr/local/mysql
```

### 3. 修改配置文件

```shell
cat <<EOF > /etc/my.cnf
[mysqld]
bind-address=0.0.0.0
port=3306
user=mysql
basedir=/usr/local/mysql
datadir=/data/mysql/data
socket=/tmp/mysql.sock
symbolic-links=0
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
character_set_server=utf8mb4
explicit_defaults_for_timestamp=true
group_concat_max_len=102400
[mysqld_safe]
log-error=/data/mysql/data/mysql.log
pid-file=/data/mysql/data/mysql.pid
EOF
```

### 4. 初始化并启动启动数据库

```shell
cd /usr/local/mysql/bin/
### 输出root的默认密码
./mysqld --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql/ --datadir=/data/mysql/data/ --user=mysql --initialize
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql 
ln -s /usr/local/mysql/bin/mysql /usr/bin 
service mysql start
systemctl enable mysql
```
### 5. 登录数据库修改root密码、导入基础数据

```shell

mysql -u root -p 
        SET PASSWORD = PASSWORD('dinghao8888'); 
        ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER; 
        FLUSH PRIVILEGES; 
        use mysql;
        update user set host = '%' where user = 'root'; 
        FLUSH PRIVILEGES; 
        create database ujy_release;
        use ujy_release; 
        source /data/mysql/ujy_demo.sql;
```
