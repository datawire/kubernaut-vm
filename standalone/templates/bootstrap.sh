#!/bin/bash

set -o verbose
set -o errexit
set -o pipefail

export KUBEADM_TOKEN="${kubeadm_token}"
export DNS_NAME="${dns_name}"
export IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
export CLUSTER_NAME="${cluster_name}"
export KUBERNETES_VERSION="$(cat /etc/kubernaut/kubernetes_version)"

set -o nounset

aws ec2 create-tags \
   --region us-east-1 \
   --resources $(curl -s http://169.254.169.254/latest/meta-data/instance-id) \
   --tags Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=owned

# We needed to match the hostname expected by kubeadm to the hostname used by kubelet
#
# see: https://github.com/kubernetes/kubeadm/issues/584
#
FULL_HOSTNAME="$(curl -s http://169.254.169.254/latest/meta-data/hostname)"
hostname "$FULL_HOSTNAME"

# Make DNS lowercase
DNS_NAME=$(echo "$DNS_NAME" | tr 'A-Z' 'a-z')

# Start services
systemctl start docker
systemctl start kubelet

# Initialize the master
cat >/tmp/kubeadm.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
nodeName: $FULL_HOSTNAME
token: $KUBEADM_TOKEN
tokenTTL: "0"
cloudProvider: aws
kubernetesVersion: v$KUBERNETES_VERSION
apiServerCertSANs:
- $DNS_NAME
- $IP_ADDRESS
EOF

kubeadm reset
kubeadm init --config /tmp/kubeadm.yaml
rm /tmp/kubeadm.yaml

# Use the local kubectl config for further kubectl operations
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install calico
kubectl apply -f /tmp/calico.yaml

# Allow all apps to run on master
kubectl taint nodes --all node-role.kubernetes.io/master-

# Allow load balancers to route to master
kubectl label nodes --all node-role.kubernetes.io/master-

# Allow the user to administer the cluster
kubectl create clusterrolebinding admin-cluster-binding --clusterrole=cluster-admin --user=admin

# Prepare the kubectl config file for download to client (DNS)
export KUBECONFIG_OUTPUT=/home/ubuntu/kubeconfig
kubeadm alpha phase kubeconfig user \
 --client-name admin \
 --apiserver-advertise-address $DNS_NAME \
 > $KUBECONFIG_OUTPUT
chown ubuntu:ubuntu $KUBECONFIG_OUTPUT
chmod 0600 $KUBECONFIG_OUTPUT

# Prepare the kubectl config file for download to client (IP address)
export KUBECONFIG_OUTPUT=/home/ubuntu/kubeconfig_ip
kubeadm alpha phase kubeconfig user \
 --client-name admin \
 --apiserver-advertise-address $IP_ADDRESS \
 > $KUBECONFIG_OUTPUT
chown ubuntu:ubuntu $KUBECONFIG_OUTPUT
chmod 0600 $KUBECONFIG_OUTPUT
