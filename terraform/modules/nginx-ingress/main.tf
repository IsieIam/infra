resource "kubernetes_namespace" "nginx-ingress" {
  #depends_on = [module.cluster]
  metadata {
    name = "nginx-ingress"
  }
}

locals {
  values = {
    controller = {
      kind = "DaemonSet"
      nodeSelector = var.node_selector
    }
    defaultBackend = {
      nodeSelector = var.node_selector
    }
  }
}

resource "helm_release" "nginx-ingress" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  name = "nginx-ingress"
  chart = "ingress-nginx"
  namespace = kubernetes_namespace.nginx-ingress.metadata[0].name

  values = [yamlencode(local.values)]
}

data "kubernetes_service" "nginx-ingress" {
  depends_on = [helm_release.nginx-ingress]
  metadata {
    name = "${helm_release.nginx-ingress.name}-ingress-nginx-controller"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }
}
