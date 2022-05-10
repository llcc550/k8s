1. 以下为测试环境 dinghaotech 账号 用户 docker-registry 上海一

```shell
docker login -u cn-east-3@KIZLHXYGZA330UHYPZM7 -p ab1e1f0187212ef03726edb5f326d701ec58e05d708c7919748fcf7c1aabd605 swr.cn-east-3.myhuaweicloud.com

kubectl --namespace xiaohuiyun create secret docker-registry image-pull-secret \
--docker-server=swr.cn-east-3.myhuaweicloud.com \
--docker-username='cn-east-3@KIZLHXYGZA330UHYPZM7' \
--docker-password='ab1e1f0187212ef03726edb5f326d701ec58e05d708c7919748fcf7c1aabd605'
```

2. 以下为新环境 wx-xiaoyang 账号 用户 docker-image 上海一

```shell
kubectl --namespace xiaohuiyun create secret docker-registry image-pull-secret \
--docker-server=swr.cn-east-3.myhuaweicloud.com \
--docker-username='cn-east-3@XGIWXJKB0GFWEWLLN4DE' \
--docker-password='e75abc730d8d80ec8ef53dc5c6df5ce1d22b120604ee834c603cf773b984e390'
```

3. 以下为新环境 wx-xiaoyang 账号 用户 docker-jenkins 上海一

```shell
docker login -u cn-east-3@ZFIK3HN0PCALT0I6BZFM -p bde405e48dfd645e9a5932c2d5600b1c4bd3834650964e5661114fb72a71edef swr.cn-east-3.myhuaweicloud.com
```

4. AK/SK生成命令参数

```shell
printf "$AK" | openssl dgst -binary -sha256 -hmac "$SK" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
```