resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_secret" "grafana-secret" {
  metadata {
    name = "grafana-secret"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    "admin-user" = "admin"
    "admin-password" = random_string.grafana-password.result
  }

  type = "Opaque"
}

resource "random_string" "grafana-password" {
  length = 16
  special = false
}

locals {
  values = {
    grafana = {
      ingress = {
        enabled = true
        hosts = [var.grafana_hostname]
      }
      admin = {
        existingSecret = kubernetes_secret.grafana-secret.metadata[0].name
      }
    }
    prometheus = {
      alertmanager = {
        enabled = false
      }
      server = {
        ingress = {
          enabled = true
          hosts = [var.prometheus_hostname]
        }
        persistentVolume = {
          enabled = false
        }
      }
    }
  }
}

resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  name = "grafana"
  chart = "grafana"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [yamlencode(local.values.grafana)]
}

data "kubernetes_service" "grafana" {
  depends_on = [helm_release.grafana]
  metadata {
    name = helm_release.grafana.name
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
}

resource "helm_release" "prometheus" {
  repository = "https://prometheus-community.github.io/helm-charts"
  name = "prometheus"
  chart = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [yamlencode(local.values.prometheus)]
}

