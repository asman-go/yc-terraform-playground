data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

data "yandex_vpc_network" "playground-network" {
    name = var.network-name
}

data "yandex_vpc_subnet" "playground-subnet" {
  name = var.subnet-name
}

resource "yandex_vpc_security_group" "playground-security-group" {
    # https://yandex.cloud/ru/docs/vpc/concepts/security-groups
  name = "plauground-security-group"
  network_id = data.yandex_vpc_network.playground-network.id
  ingress {
    description = "Allow SSH"
    protocol = "ANY"
    port = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    protocol = "TCP"
    port = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS"
    protocol = "TCP"
    port = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description       = "Permit ANY"
    protocol          = "ANY"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "instance" {
  name = "instance-playground-with-docker-container"

  platform_id = "standard-v3" # Intel Ice Lake, https://yandex.cloud/ru/docs/compute/concepts/vm-platforms
  zone        = var.zone

  service_account_id = var.service-account-id
  resources {
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
        yandex_vpc_security_group.playground-security-group.id
    ]
  }

  metadata = {
    docker-container-declaration = file("${path.module}/configs/declaration.yaml")
    # docker-compose = file("${path.module}/configs/docker-compose.yaml")
    user-data = file("${path.module}/configs/cloud_config.yaml")
  }
}

output "external_ip" {
  value = yandex_compute_instance.instance.network_interface.0.nat_ip_address
}
