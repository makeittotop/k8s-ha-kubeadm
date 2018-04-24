#!/bin/bash -x
set -e

export etcd0-ip-address=172.17.0.50
export etcd1-ip-address=172.17.0.51
export etcd2-ip-address=172.17.0.52
export pod-cidr=10.32.0.0/12
export load-balancer-ip=172.17.0.49
export PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')

cat >config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: ${PRIVATE_IP}
etcd:
  endpoints:
  - https://${etcd0-ip-address}:2379
  - https://${etcd1-ip-address}:2379
  - https://${etcd2-ip-address}:2379
  caFile: /etc/kubernetes/pki/etcd/ca.pem
  certFile: /etc/kubernetes/pki/etcd/client.pem
  keyFile: /etc/kubernetes/pki/etcd/client-key.pem
networking:
  podSubnet: ${pod-cidr}
apiServerCertSANs:
- ${load-balancer-ip}
apiServerExtraArgs:
  apiserver-count: "3"
EOF

kubeadm init --config=config.yaml && echo "$hostname kubeadm deployment done!"
mkdir -pv /vagrant/pki
cp /etc/kubernetes/pki/{ca*,sa*} /vagrant/pki/