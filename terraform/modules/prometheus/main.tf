resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "random_string" "grafana-password" {
  length = 16
  special = false
}

# переменные для helm чартов прома и графаны
locals {
  values = {
    # переменные для графаны
    grafana = {
      ingress = {
        enabled = true
        hosts = [var.grafana_hostname]
      }
      adminPassword: random_string.grafana-password.result
    }
    # переменные для прометея
    prometheus = {
      ingress = {
        enabled = true
        hosts = [var.prometheus_hostname]
      }
      prometheusSpec = {
        serviceMonitorSelectorNilUsesHelmValues = false
      }
    }
  }
}

resource "helm_release" "prometheus" {
  repository = "https://prometheus-community.github.io/helm-charts"
  name = "prometheus"
  chart = "kube-prometheus-stack"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [yamlencode(local.values)]
}

#data "kubernetes_service" "prometheus" {
#  depends_on = [helm_release.prometheus]
#  metadata {
#    name = helm_release.prometheus.name
#    namespace = kubernetes_namespace.monitoring.metadata[0].name
#  }
#}
