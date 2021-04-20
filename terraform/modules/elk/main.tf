resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }
}

# переменные для helm чартов elasticsearch
locals {
  values = {
    # переменные для elasticsearch
    # переменные для kibana
    kibana = {
      ingress = {
        enabled = true
        path = "/"
        hosts = [var.kibana_hostname]
      }
    }
    fluent-bit = {
      backend = {
        type = "es"
        es = {
          host = "elasticsearch-master"
          time_key = "@ts"
        }
      }
    }
  }
}

resource "helm_release" "elasticsearch" {
  repository = "https://helm.elastic.co"
  name = "elasticsearch"
  chart = "elasticsearch"
  namespace = kubernetes_namespace.observability.metadata[0].name

  # values = [yamlencode(local.values)]
}

resource "helm_release" "kibana" {
  repository = "https://helm.elastic.co"
  name = "kibana"
  chart = "kibana"
  namespace = kubernetes_namespace.observability.metadata[0].name

  values = [yamlencode(local.values.kibana)]
}

resource "helm_release" "filebeat" {
  repository = "https://helm.elastic.co"
  name = "filebeat"
  chart = "filebeat"
  namespace = kubernetes_namespace.observability.metadata[0].name
}

#resource "helm_release" "fluent-bit" {
#  repository = "https://fluent.github.io/helm-charts"
#  name = "fluent-bit"
#  chart = "fluent-bit"
#  namespace = kubernetes_namespace.observability.metadata[0].name
#}


#resource "helm_release" "fluentd" {
#  repository = "https://fluent.github.io/helm-charts"
#  name = "fluentd"
#  chart = "fluentd"
#  namespace = kubernetes_namespace.observability.metadata[0].name
#}
