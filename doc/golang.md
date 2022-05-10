### centos7安装golang1.18.0

```shell
cd /data/tmp
wget https://cdn.u-jy.cn/go1.18.linux-amd64.tar.gz
tar -zxvf go1.18.linux-amd64.tar.gz -C /usr/local

echo "export GOROOT=/usr/local/go" >> /etc/profile
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
echo "export GOPATH=/data/code/goworkspace" >> /etc/profile
echo "export GOPROXY=https://goproxy.cn,direct" >> /etc/profile
source /etc/profile
```