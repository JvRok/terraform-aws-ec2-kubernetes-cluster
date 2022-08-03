#!/bin/bash

#Update it all to start with
dnf -y upgrade

#SElinux and Swap disable

setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# swapoff -a to disable swapping
# off by default I believe in centos9. But to make sure.
swapoff -a
# sed to comment the swap partition in /etc/fstab
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

#Install grubby and update cgroup
dnf install -y grubby && \
  grubby \
  --update-kernel=ALL \
  --args="systemd.unified_cgroup_hierarchy=1"

#ContainerD Install
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

#Network settings kubernetes requires
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
# Currently seeing issues here in centos9 with interpreting, look at this later.
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

#Look at implementing firewalld rules later. FirewallD Disabled on centos9 by default
#systemctl disable firewalld
#systemctl stop firewalld


cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Already disabled it myself, these comments below are from kubernetes docs
# Set SELinux in permissive mode (effectively disabling it)
#setenforce 0
#sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet


#Now its time for pod racing
kubeadm init --pod-network-cidr=192.168.0.0/16 --token ${init_token}

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

curl https://docs.projectcalico.org/manifests/calico.yaml -O

/usr/bin/kubectl  apply -f calico.yaml --kubeconfig=/etc/kubernetes/admin.conf 
if [ "${apiaccess}" = true ]
then
  echo "insecureToken,ec2-admin-user,ec2-admin-user,cluster-admin,cluster-admin" > /etc/kubernetes/pki/bearer-tokens.csv
  /usr/bin/kubectl create serviceaccount ec2-admin-user --kubeconfig=/etc/kubernetes/admin.conf 
  /usr/bin/kubectl create clusterrolebinding ec2-admin-user-crb --clusterrole=cluster-admin --user=ec2-admin-user --kubeconfig=/etc/kubernetes/admin.conf 
  /usr/bin/sed -i '/- kube-apiserver/a \
    - --token-auth-file=/etc/kubernetes/pki/bearer-tokens.csv' /etc/kubernetes/manifests/kube-apiserver.yaml
fi
#calicoctl not installed here, could be done?