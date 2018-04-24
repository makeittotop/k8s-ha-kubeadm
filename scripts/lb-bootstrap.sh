#!/bin/bash -e
set -x

apt-get install -y keepalived

cat >/etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
 global_defs {
   router_id LVS_DEVEL
 }

 vrrp_script check_apiserver {
   script "/etc/keepalived/check_apiserver.sh"
   interval 3
   weight -2
   fall 10
   rise 2
 }

 vrrp_instance VI_1 {
     state ${state}
     interface ${eth}
     virtual_router_id 51
     priority ${priority}
     authentication {
         auth_type PASS
         auth_pass 4be37dc3b4c90194d1600c483e10ad1d
     }
     virtual_ipaddress {
         ${load_balancer_ip}
     }
     track_script {
         check_apiserver
     }
 }
EOF

cat >/etc/keepalived/check_apiserver.sh <<EOF
#!/bin/sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q ${load_balancer_ip}; then
    curl --silent --max-time 2 --insecure https:/${load_balancer_ip}:6443/ -o /dev/null || errorExit "Error GET https://${load_balancer_ip}:6443/"
fi
EOF

systemctl daemon-reload
systemctl restart keepalived
systemctl enable keepalived