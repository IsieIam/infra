resource "yandex_compute_instance" "app" {
  name = var.instance_name
  labels = {
    tags = var.instance_name
  }
  zone = var.zone
  resources {
    cores         = var.cpu_count
    memory        = var.ram_size
    core_fraction = var.cpu_usage
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }

  metadata = {
    ssh-keys = var.ssh_keys
  }
}
