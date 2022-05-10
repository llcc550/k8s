#!/bin/bash

kubectl create namespace demacia

sed -i 's#/data/code/goworkspace/demacia-$serviceName#/data/code/goworkspace#g' `grep -rl '/data/code/goworkspace/demacia-$serviceName' ./* --exclude=init.sh`

for i in $(find -name build.sh); do
    sh "$i"
done

kubectl apply -f /data/code/config/test/demacia/ingress.yaml

cd /data/code/config && git checkout .