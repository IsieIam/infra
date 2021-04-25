terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "= 1.3.2"
    }
    http = {
      source = "hashicorp/http"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "= 1.13.2"
    }
    local = {
      source = "hashicorp/local"
      version = "= 2.0.0"
    }
    random = {
      source = "hashicorp/random"
    }
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
