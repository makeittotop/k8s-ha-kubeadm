#!/bin/bash -x
set -e

cp /vagrant/pki/* /etc/kubernetes/pki/ -rfv

export etcd0_ip_address=172.17.0.50
export etcd1_ip_address=172.17.0.51
export etcd2_ip_address=172.17.0.52
export pod_cidr=10.32.0.0/12
export load_balancer_ip=172.17.0.49
export PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')

cat >config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: ${PRIVATE_IP}
etcd:
  endpoints:
  - https://${etcd0_ip_address}:2379
  - https://${etcd1_ip_address}:2379
  - https://${etcd2_ip_address}:2379
  caFile: /etc/kubernetes/pki/etcd/ca.pem
  certFile: /etc/kubernetes/pki/etcd/client.pem
  keyFile: /etc/kubernetes/pki/etcd/client-key.pem
networking:
  podSubnet: ${pod_cidr}
apiServerCertSANs:
- ${load_balancer_ip}
apiServerExtraArgs:
  apiserver-count: "3"
EOF

kubeadm init --config=config.yaml && echo "$hostname kubeadm deployment done!"