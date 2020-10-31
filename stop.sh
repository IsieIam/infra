#!/bin/bash

# удаляем всю инфру терраформа
cd terraform
terraform destroy --auto-approve=true
