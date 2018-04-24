# -*- mode: ruby -*-
# vi: set ft=ruby :
# Every Vagrant development environment requires a box. You can search for
# boxes at https://atlas.hashicorp.com/search.
BOX_IMAGE = "bento/ubuntu-16.04"
MASTER_NODE_COUNT = 3
WORKER_COUNT=2
#PROVISIONED_MASTER_COUNT=0
Vagrant.configure("2") do |config|
 config.vm.provider "virtualbox" do |v|
  v.linked_clone = true
  v.memory = 4096
  v.cpus = 2
 end

 # Install avahi on all machines
 config.vm.provision "shell", inline: <<-SHELL
  apt-get install -y avahi-daemon libnss-mdns
 SHELL

 # Install kubeadm scripts on all machines
 config.vm.provision "shell", path: "scripts/kubeadm-bootstrap-common.sh"

 # master0
 config.vm.define "kube-master0" do |subconfig|
   subconfig.vm.box = BOX_IMAGE
   subconfig.vm.hostname = "kube-master0"
   subconfig.vm.network :private_network, ip: "172.17.0.50"

   # master0 part 1 - kubeadm bootstrap
   subconfig.vm.provision "shell", path: "scripts/kubeadm-master0-bootstrap-part1.sh"
   # bootstrap etcd cluster on all machines
   subconfig.vm.provision "shell", path: "scripts/etcd-cluster-bootstrap.sh"
   # master0 part 2 - kubeadm bootstrap
   #subconfig.vm.provision "shell", path: "scripts/kubeadm-master0-bootstrap-part2.sh"   

   #PROVISIONED_MASTER_COUNT += 1
 end

# other masters
 (1..(MASTER_NODE_COUNT - 1)).each do |i|
  config.vm.define "kube-master#{i}" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "kube-master#{i}"
    subconfig.vm.network :private_network, ip: "172.17.0.#{i + 50}" #type: "dhcp" #

    # other masters part 1 - kubeadm bootstrap
    subconfig.vm.provision "shell", path: "scripts/kubeadm-other-masters-bootstrap-part1.sh"
    # bootstrap etcd cluster on all machines
    subconfig.vm.provision "shell", path: "scripts/etcd-cluster-bootstrap.sh"    
    # other masters part 2 - kubeadm bootstrap
    #subconfig.vm.provision "shell", path: "scripts/kubeadm-other-masters-bootstrap-part2.sh"
  end
 end

 # lb bootstrap
 #config.vm.provision "shell", path: "lb-bootstrap.sh"

 # bootstrap etcd cluster on all machines
#config.vm.provision "shell1", inline: <<-SHELL
 # systemctl start etcd
#SHELL

# master0 part 2 - kubeadm bootstrap
#config.vm.provision "shell2", path: "scripts/kubeadm-master0-bootstrap-part2.sh"

# other masters part 2 - kubeadm bootstrap
#config.vm.provision "shell3", path: "scripts/kubeadm-other-masters-bootstrap-part2.sh"

end