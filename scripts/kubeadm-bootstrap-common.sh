#!/bin/bash -x
set -e
 
# disable swap
swapoff -a

# install docker
apt-get update
apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
 add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
 
# install kubeadm kubectl kubelet
# rm /etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
# install cfssl
curl -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
curl -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x /usr/local/bin/cfssl*
# configure /etc/hosts
cat >/etc/hosts <<EOF
127.0.0.1 localhost
172.17.0.50 kube-master0
172.17.0.51 kube-master1 
172.17.0.52 kube-master2 
172.17.0.49 kube-cluster 
EOF