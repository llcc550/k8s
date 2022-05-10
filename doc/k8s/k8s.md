## centos7 安装kubernetes集群-1.21.5

### 1.安装kubelet,docker

```shell
# node-name 将会是该机器在 kubernetes 集群中的节点名字，自行定义并区分master和worker
hostnamectl set-hostname node-name
echo "127.0.0.1   $(hostname)" >> /etc/hosts
curl https://cdn.u-jy.cn/k8s/install_kubelet.sh | bash -

# 根据 df -hT /var/lib/docker 自行判断是否需要在/etc/docker/daemon.json添加配置项 "data-root":"/data/docker",
# /data/docker 自行修改为合适的目录。
# 如果修改，需执行 
systemctl stop docker
/bin/cp -rf /var/lib/docker/* /data/docker
systemctl daemon-reload 
systemctl restart docker
```

### 2. 设置master节点信息

```shell
# 替换 x.x.x.x 为 master 节点实际 IP（请使用内网 IP）
export MASTER_IP=x.x.x.x 
# 替换 apiserver.demo 为 您想要的 dnsName
export APISERVER_NAME=apiserver.demo
echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts

```

### 3. 以下只在 master 节点执行

```shell
# k8s 容器组所在的网段，该网段安装完成后，由 kubernetes 创建，事先并不存在于您的物理网络中
export POD_SUBNET=10.100.0.0/16

# 初始化master节点
curl https://cdn.u-jy.cn/k8s/init_master.sh | bash -

# 安装网络插件
kubectl apply -f https://cdn.u-jy.cn/k8s/calico-operator.yaml
wget https://cdn.u-jy.cn/k8s/flannel-v0.14.0.yaml
sed -i "s#10.244.0.0/16#${POD_SUBNET}#" flannel-v0.14.0.yaml
kubectl apply -f ./flannel-v0.14.0.yaml

# 如果集群节点资源不足，需要master也参与工作负载。
kubectl taint nodes master-node node-role.kubernetes.io/master=:NoSchedule-

# 修改NodePort的范围
vim /etc/kubernetes/manifests/kube-apiserver.yaml
# 向其中添加 - --service-node-port-range=80-37999 （请使用您自己需要的端口范围）。
# 若修改此项，请耐心等待apiserver重新启动

# 获取worker节点加入集群所需的命令
kubeadm token create --print-join-command
```

## 4. 以下只在 worker 节点执行

```shell
# 替换为 master 节点上 执行 kubeadm token create --print-join-command 命令的输出
kubeadm join apiserver.release:6443 --token cdhkvn.u7815ktogkiny9b3 \
        --discovery-token-ca-cert-hash sha256:467f2ae0b4e6c0a334c4c09e26d1ead80007b5869d1a2f63881cc95a9ca032bc 
```

## 5. kubectl 自动补全

```shell
yum install -y bash-completion 
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

## 6. kuboard

```shell
 docker run -d --restart=unless-stopped --name=kuboard -p 30080:80/tcp -p 30081:10081/tcp -v /data/kuboard:/data eipwork/kuboard:v3
```