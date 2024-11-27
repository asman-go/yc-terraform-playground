data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

data "yandex_vpc_subnet" "playground-subnet" {
  name = var.subnet-name
}

resource "yandex_compute_instance" "instance" {
  name = "instance-playground-with-docker-compose"

  platform_id = "standard-v3" # Intel Ice Lake, https://yandex.cloud/ru/docs/compute/concepts/vm-platforms
  zone        = var.zone

  allow_stopping_for_update = true  # Что бы можно было менять resources поле через terraform
  service_account_id = var.service-account-id
  resources {
    core_fraction = 50  # 50%
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.playground-subnet.id
    security_group_ids = [
      var.security-group-id
    ]
  }

  metadata = {
    # docker-container-declaration = file("${path.module}/configs/declaration.yaml")
    docker-compose = file("${path.module}/configs/docker-compose.yaml")
    user-data      = file("${path.module}/configs/cloud_config.yaml")
  }
}

output "external_ip" {
  value = yandex_compute_instance.instance.network_interface.0.nat_ip_address
}
