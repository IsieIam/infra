output "load_balancer_ip" {
  value = module.nginx-ingress.load_balancer_ip
  description = "Nginx ingress load balancer ip"
}
