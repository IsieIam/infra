output "grafana_admin_password" {
  value = random_string.grafana-password.result
}
output "grafana_hostname" {
  value = var.grafana_hostname
}
output "prometheus_hostname" {
  value = var.prometheus_hostname
}