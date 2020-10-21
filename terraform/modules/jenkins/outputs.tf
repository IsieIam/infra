output "external_ip_address" {
  value = yandex_compute_instance.app.network_interface.0.nat_ip_address
}
