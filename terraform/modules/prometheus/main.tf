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
    additionalPrometheusRulesMap = {
      rule-name = {
        groups = [
          {
            name = "Nginx status",
            rules = [
              {
                alert = "Nginx DOWN",
                expr = "nginx_up == 0",
                for = "10s",
                labels = {
                  severity = "warning"
                }
              }
            ]
          }
        ]
      }
    }
    # переменные для графаны
    grafana = {
      ingress = {
        enabled = true
        hosts = [var.grafana_hostname]
      }
      adminPassword: random_string.grafana-password.result
      sidecar = {
        dashboards = {
          enabled = true
          label = "grafana_dashboard"
        }
      }
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
    # переменные для alertmanager
    alertmanager = {
      enabled = true
      ingress = {
        enabled = true
        hosts = [var.alertmanager_hostname]
      }
      config = {
        global = {
          slack_api_url = "https://hooks.slack.com/services/fake/fake/fake",
          resolve_timeout = "30s"
        }
        route = {
          routes = [
            {
              match = {
                alertname = "Watchdog"
              }
              receiver = "null"
            },
            {
              match = {
                severity = "warning"
              }
              receiver = "slack-notifications"
            },
            {
              match = {
                severity = "critical"
              }
              receiver = "slack-notifications"
            }
          ]
        }
        receivers = [
          {
            name = "null"
          },
          {
            name = "slack-notifications"
            slack_configs = [
              {
                channel = "#test",
                send_resolved = true
              },
            ]
          }
        ]
      }
    }
  }
}

resource "helm_release" "prometheus" {
  repository = "https://prometheus-community.github.io/helm-charts"
  name = "prometheus"
  chart = "kube-prometheus-stack"
  version    = "14.9.0"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [yamlencode(local.values)]
}
