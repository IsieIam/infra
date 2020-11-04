#!/bin/bash

#sudo aptdcon --safe-upgrade
while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
   sleep 1
done

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update

sudo apt-get -y install openjdk-8-jdk
sudo apt-get -y install jenkins


curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client



curl -LO https://get.helm.sh/helm-v3.4.0-linux-amd64.tar.gz
tar -zxvf helm-v3.4.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

echo "kubectl version"
kubectl version --client

echo "helm version"
helm version

cd /var/lib/jenkins
sudo mkdir .kube
sudo mv /tmp/kubeconfig /var/lib/jenkins/.kube/kubeconfig
sudo chown jenkins /var/lib/jenkins/.kube/kubeconfig
sudo chown jenkins /var/lib/jenkins/.kube
