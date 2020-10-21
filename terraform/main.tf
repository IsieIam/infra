provider "yandex" {
  token = var.yandex_token
  #service_account_key_file = var.service_account_key_file
  cloud_id = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
}

locals {
  cluster_service_account_name = "${var.cluster_name}-cluster"
  cluster_node_service_account_name = "${var.cluster_name}-node"

  cluster_node_group_configs = {
#    service = {
#      name = "service"
#      cpu = 4
#      memory = 8
#      disk = {
#        size = 64
#        type = "network-ssd"
#      }
#    }
#    nfs = {
#      name = "nfs"
#      cpu = 2
#      memory = 2
#      disk = {
#        size = 64
#        type = "network-ssd"
#      }
#    }
    web = {
      name = "web"
      cpu = 4
      memory = 8
      disk = {
        size = 64
        type = "network-ssd"
      }
    }
  }
  cluster_node_groups = {
    for key, config in local.cluster_node_group_configs:
      key => merge(config, {
        fixed_scale = lookup(var.node_groups_scale[key], "fixed_scale", false) != false ? [var.node_groups_scale[key].fixed_scale] : []
        auto_scale = lookup(var.node_groups_scale[key], "auto_scale", false) != false ? [var.node_groups_scale[key].auto_scale] : []
      })
  }
  node_selectors = {
    for key, id in module.cluster.node_group_ids:
      key => {
        "yandex.cloud/node-group-id" = id
      }
  }
}

module "vpc" {
  source = "./modules/vpc"
  zones = var.yandex_zones
  subnet = "10.0.0.0/14"
  name = var.cluster_name
}

module "iam" {
  source = "./modules/iam"

  cluster_folder_id = var.yandex_folder_id
  cluster_service_account_name = local.cluster_service_account_name
  cluster_node_service_account_name = local.cluster_node_service_account_name
}

module "jenkins" {
  source = "./modules/jenkins"
  ssh_keys = module.admins.ssh_keys
  app_disk_image = var.jenkins_image_id
  cpu_count = 2
  ram_size = 4
  cpu_usage = 100
  instance_name = "jenkins"
  subnet_id = var.jenkins_subnet_id
  zone = var.yandex_zones[0]
}


module "cluster" {
  source = "./modules/cluster"

  name = var.cluster_name
  public = true
  kube_version = var.cluster_version
  release_channel = var.cluster_release_channel
  vpc_id = module.vpc.vpc_id
  location_subnets = module.vpc.location_subnets
  cluster_service_account_id = module.iam.cluster_service_account_id
  node_service_account_id = module.iam.cluster_node_service_account_id
  cluster_node_groups = local.cluster_node_groups
  ssh_keys = module.admins.ssh_keys
  dep = [
    module.iam.req
  ]
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host = module.cluster.external_v4_endpoint
    cluster_ca_certificate = module.cluster.ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "yc"
      args = [
        "managed-kubernetes",
        "create-token",
        "--cloud-id", var.yandex_cloud_id,
        "--folder-id", var.yandex_folder_id,
        "--token", var.yandex_token,
      ]
    }
  }
}

provider "kubernetes" {
  load_config_file = false

  host = module.cluster.external_v4_endpoint
  cluster_ca_certificate = module.cluster.ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "yc"
    args = [
      "managed-kubernetes",
      "create-token",
      "--cloud-id", var.yandex_cloud_id,
      "--folder-id", var.yandex_folder_id,
      "--token", var.yandex_token,
    ]
  }
}

module "nginx-ingress" {
  source = "./modules/nginx-ingress"

  node_selector = local.node_selectors["web"]
  depends_on = [module.cluster.node_group_ids]
}

provider "kubectl" {
  load_config_file = false

  host = module.cluster.external_v4_endpoint
  cluster_ca_certificate = module.cluster.ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "yc"
    args = [
      "managed-kubernetes",
      "create-token",
      "--cloud-id", var.yandex_cloud_id,
      "--folder-id", var.yandex_folder_id,
      "--token", var.yandex_token,
    ]
  }
}

module "admins" {
  source = "./modules/admins"

  admins = var.admins
  cluster_name = var.cluster_name
  cluster_endpoint = module.cluster.external_v4_endpoint
}

provider "local" {}

provider "random" {}

