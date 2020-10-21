output "load_balancer_ip" {
  value = module.nginx-ingress.load_balancer_ip
  description = "Nginx ingress load balancer ip"
}
output "jenkins_ip" {
  value = module.jenkins.external_ip_address
  description = "Jenkins external ip address"
}
