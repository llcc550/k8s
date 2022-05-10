kubectl apply -f strimzi-cluster-operator-0.28.0.yaml -n kafka
kubectl apply -f storageclass.yaml -n kafka
kubectl apply -f rbac.yaml -n kafka
kubectl apply -f kafka.yaml -n kafka