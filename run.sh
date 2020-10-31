#!/bin/bash

# устанавливаем терраформ
cd terraform
terraform apply --auto-approve=true

# получаем конфиг нашего кластера на машинку где запустили
yc managed-kubernetes cluster get-credentials otus-cluster --external --force

# деплой прометея
echo "prometheus"