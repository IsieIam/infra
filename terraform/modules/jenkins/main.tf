resource "yandex_compute_image" "jenkins" {
  name       = "jenkins"
  source_family = "ubuntu-1804-lts"
}

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
      image_id = yandex_compute_image.jenkins.id
      size = 15
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }

  metadata = {
    ssh-keys = var.ssh_keys
  }
  provisioner "file" {
    source      = "./modules/jenkins/install.sh"
    destination = "/tmp/install.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      private_key = file(var.private_key_path)
      host        = yandex_compute_instance.app.network_interface.0.nat_ip_address
    }
  }

  provisioner "file" {
    source      = "./output/kubeconfigs/appuser.yaml"
    destination = "/tmp/kubeconfig"
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      private_key = file(var.private_key_path)
      host        = yandex_compute_instance.app.network_interface.0.nat_ip_address
      #host        = self.network_interface.0.nat_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh",
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      private_key = file(var.private_key_path)
      host        = yandex_compute_instance.app.network_interface.0.nat_ip_address
    }
  }
}
