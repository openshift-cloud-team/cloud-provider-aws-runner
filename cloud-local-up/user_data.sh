#! /bin/bash

set -x

# Export region and IAM policy for nodes
# The variables are passed by format() from terraform
export AWS_ACCESS_KEY_ID=%s
export AWS_SECRET_ACCESS_KEY=%s
export AWS_NODE_ZONE=%s
export CLUSTER_CIDR=%s
export NODE_ROLE_ARN=%s

# Set plugin for in-cluster networking, set volume plugin to default storage solution for kcm
export NET_PLUGIN=kubenet
export EXTERNAL_CLOUD_VOLUME_PLUGIN="aws"

dnf install make golang dnf-plugins-core -y
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo -y
sudo dnf install docker-ce docker-ce-cli -y
systemctl enable docker
systemctl start docker

echo 'export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH=$GOPATH/src/k8s.io/kubernetes/third_party/etcd:${PATH}
export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig
export CLUSTER_CIDR='$CLUSTER_CIDR'
export NET_PLUGIN=kubenet
export EXTERNAL_CLOUD_VOLUME_PLUGIN=aws

alias kubectl=$GOPATH/src/k8s.io/kubernetes/cluster/kubectl.sh 
' | tee -a ~/.bashrc

# Set missing environment variables in cloud-init, to duplicate missing user home
export GOPATH=/root/go
export PATH="$GOPATH/src/k8s.io/kubernetes/third_party/etcd:${PATH}"
export HOME=/root
export GOOS=linux

mkdir -p $GOPATH/src/k8s.io
cd $GOPATH/src/k8s.io

# Clone kube
git clone https://github.com/kubernetes/kubernetes
# Clone cloud-provider-aws
git clone https://github.com/kubernetes/cloud-provider-aws
# Clone network plugins
git clone https://github.com/containernetworking/plugins
mkdir -p /etc/cni/net.d  /opt/cni/bin

cd kubernetes
./hack/install-etcd.sh
# Hack: patch kube scripts to work with awailable go1.14.0 version in fedora-32
sed -i 's/minimum_go_version=.*/minimum_go_version=go1.14.0/g' ./hack/lib/golang.sh

# Build and configure network plugins
cd ../plugins
./build_linux.sh
cp bin/* /opt/cni/bin/

echo '{
    "cniVersion": "0.3.1",
    "name": "mynet",
    "plugins": [
        {
            "type": "bridge",
            "bridge": "cni0",
            "isGateway": true,
            "ipMasq": true,
            "ipam": {
                "type": "host-local",
                "subnet": "'$CLUSTER_CIDR'",
                "routes": [
                    { "dst": "0.0.0.0/0"   }
                ]
            }
        },
        {
            "type": "portmap",
            "capabilities": {"portMappings": true},
            "snat": true
        }
    ]
}' > /etc/cni/net.d/10-mynet.conflist

echo '{
    "cniVersion": "0.3.1",
    "type": "loopback"
}' > /etc/cni/net.d/99-loopback.conf

cd ../cloud-provider-aws
./hack/local-up-cluster.sh
