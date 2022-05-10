### centos7安装nfs

```shell
yum -y install nfs-utils
systemctl enable rpcbind
systemctl enable nfs
mkdir /data/nfs
chmod 777 /data/nfs
# 192.168.0.111 自行替换
echo "/data/nfs     192.168.0.111/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
systemctl start rpcbind
systemctl start nfs
```