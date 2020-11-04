output "load_balancer_ip" {
  value = module.nginx-ingress.load_balancer_ip
  description = "Nginx ingress load balancer ip"
}
output "jenkins_ip" {
  value = module.jenkins.external_ip_address
  description = "Jenkins external ip address"
}
output "grafana-password" {
  value = module.grafana.grafana_admin_password
  description = "Grafana admin user password"
}
output "grafana-hostname" {
  value = module.grafana.grafana_hostname
  description = "Grafana hostname"
}
output "prometheus-hostname" {
  value = module.grafana.prometheus_hostname
  description = "Prometheus hostname"
}