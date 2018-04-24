#!/bin/bash -x
set -e

export PEER_NAME=$(hostname)
export PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')

#yes y | ssh-keygen -t rsa -b 2048 -C "" -N "" -f ~/.ssh/id_rsa
mkdir -p /etc/kubernetes/pki/etcd
cd /etc/kubernetes/pki/etcd
cp /vagrant/etcd/ca.pem .
cp /vagrant/etcd/ca-key.pem .
cp /vagrant/etcd/client.pem .
cp /vagrant/etcd/client-key.pem .
cp /vagrant/etcd/ca-config.json .

cfssl print-defaults csr > config.json
sed -i '0,/CN/{s/example\.net/'"$PEER_NAME"'/}' config.json
sed -i 's/www\.example\.net/'"$PRIVATE_IP"'/' config.json
sed -i 's/example\.net/'"$PEER_NAME"'/' config.json

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server config.json | cfssljson -bare server
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer config.json | cfssljson -bare peer

export state=BACKUP
export eth=eth1
export priority=100
export load_balancer_ip=172.17.0.49
echo $PWD
. /vagrant/scripts/lb-bootstrap.sh
