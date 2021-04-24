#!/bin/bash

# set -o errexit

# Ждем освобожение apt
while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
   sleep 1
done
# добавлям количество попыток apt на скачивание
sudo echo 'APT::Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries

# добавляем репо дженка и делаем апдейт списка пакетов
echo "Install Jenkins: add repo"
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
# Ждем освобожение apt
while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
   sleep 1
done

sleep 30

# ставим  git
sudo apt -y install git

# ставим  docker
sudo apt -y install docker.io

# стаим kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

# ставим helm
curl -LO https://get.helm.sh/helm-v3.4.0-linux-amd64.tar.gz
tar -zxvf helm-v3.4.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

# выводим на всякий случай версии kubectl и helm
echo "kubectl version"
kubectl version --client

echo "helm version"
helm version

# ставим gitversion - не актульано или не для ubuntu - у gitversion есть проблемы с запуском на ней
# wget https://github.com/GitTools/GitVersion/releases/download/5.3.7/gitversion-ubuntu.18.04-x64-5.3.7.tar.gz
# tar -xvf gitversion-ubuntu.18.04-x64-5.3.7.tar.gz
#sudo chmod +x ./gitversion
# sudo mv gitversion /usr/local/bin

# Ждем освобожение apt
#while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
#   sleep 1
#done

# ставим сам дженк и яву для него
echo "Install OpenJDK"
sudo apt-get -y install openjdk-8-jdk
echo "Install Jenkins"

sudo apt-get -y install jenkins
echo "Install Jenkins: done"

# закидываем в kubeconfig полученный при создании кластера в домашнюю директорию дженка и даем дженку на него права
cd /var/lib/jenkins
sudo mkdir .kube
sudo mv /tmp/kubeconfig /var/lib/jenkins/.kube/kubeconfig
sudo chown jenkins /var/lib/jenkins/.kube/kubeconfig
sudo chown jenkins /var/lib/jenkins/.kube

# добавляем права дженку на запуск докера
sudo usermod -a -G docker jenkins
sudo systemctl restart jenkins

# узнаем пароль дженка
# ждем его появления
while  ! sudo test -f /var/lib/jenkins/secrets/initialAdminPassword; do
   echo "wait for file /var/lib/jenkins/secrets/initialAdminPassword"
   sleep 5
done
echo "got file, here it is"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# пробуем заменить дефолтный пароль дженка
#while  ! sudo test -f /var/lib/jenkins/secrets/initialAdminPassword; do
#   echo "wait for file /var/lib/jenkins/secrets/initialAdminPassword"
#   sleep 5
#done
#echo "got file"
#sudo echo "qq123" > /var/lib/jenkins/secrets/initialAdminPassword
