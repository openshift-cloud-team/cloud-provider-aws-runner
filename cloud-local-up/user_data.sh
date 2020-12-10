#! /bin/bash

set -x

# Export region and IAM policy for nodes
# The variables are passed by format() from terraform
export AWS_ACCESS_KEY_ID=%s
export AWS_SECRET_ACCESS_KEY=%s
export AWS_NODE_ZONE=%s
cluster_cidr=%s
export CLUSTER_CIDR=$cluster_cidr
export NODE_ROLE_ARN=%s

# Set plugin for in-cluster networking
# export NET_PLUGIN=kubenet

dnf install docker make golang -y 
systemctl enable docker
systemctl start docker

echo 'export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH=$GOPATH/src/k8s.io/kubernetes/third_party/etcd:${PATH}
export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig
export CLUSTER_CIDR='$cluster_cidr'
# export NET_PLUGIN=kubenet

alias kubectl=$GOPATH/src/k8s.io/kubernetes/cluster/kubectl.sh 
' | tee -a ~/.bashrc

# Set missing environment variables in cloud-init, to duplicate missing user home
export GOPATH=/root/go
export PATH="$GOPATH/src/k8s.io/kubernetes/third_party/etcd:${PATH}"
export HOME=/root
export GOOS=linux

# Clone kube
mkdir -p $GOPATH/src/k8s.io
cd $GOPATH/src/k8s.io
git clone https://github.com/kubernetes/kubernetes

# Clone cloud-provider-aws
git clone https://github.com/kubernetes/cloud-provider-aws

cd kubernetes
./hack/install-etcd.sh

# Hack: patch kube scripts to work with awailable go1.14.0 version in fedora-32
sed -i 's/minimum_go_version=.*/minimum_go_version=go1.14.0/g' ./hack/lib/golang.sh

cd ../cloud-provider-aws
./hack/local-up-cluster.sh
