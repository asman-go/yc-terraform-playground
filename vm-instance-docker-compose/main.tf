locals {
  subdomain-name = "vmpg"
  device-name    = "pgdata"
  type-postgres  = "postgres"
  type-nginx     = "nginx"
  default-user   = "yc-user"
}

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

data "yandex_vpc_subnet" "playground-subnet" {
  name = var.subnet-name
}

resource "yandex_vpc_address" "addr" {
  name = "instance-adress"
  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_compute_disk" "pg_data_disk" {
  count = var.compose-type == local.type-postgres ? 1 : 0
  name  = "pg-data-disk"
  type  = "network-hdd"
  zone  = var.zone
  size  = 10
}

resource "yandex_compute_instance" "instance" {
  name = "instance-playground-with-docker-compose"

  platform_id = "standard-v3" # Intel Ice Lake, https://yandex.cloud/ru/docs/compute/concepts/vm-platforms
  zone        = var.zone

  allow_stopping_for_update = true # Что бы можно было менять resources поле через terraform
  service_account_id        = var.service-account-id
  resources {
    core_fraction = 50 # 50%
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }

  dynamic "secondary_disk" {
    # Заполняем блок только при условии, что нужен диск второй (для postgres)
    for_each = var.compose-type == local.type-postgres ? [1] : []

    content {
      disk_id     = yandex_compute_disk.pg_data_disk.0.id
      device_name = local.device-name
    }
  }

  # secondary_disk {
  #   disk_id     = var.compose-type == local.type-postgres ?  : null
  #   device_name = local.device-name
  # }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.playground-subnet.id
    # Управляем, какие порты открываем
    security_group_ids = [
      var.security-group-id
    ]
    # Если хотим открыть наружу (дать публичный адрес)
    nat            = true
    nat_ip_address = yandex_vpc_address.addr.external_ipv4_address[0].address
  }

  metadata = {
    # docker-compose = file("${path.module}/configs/${var.compose-type}.docker-compose.yaml")
    # user-data      = file("${path.module}/configs/cloud_config.yaml")
    # https://developer.hashicorp.com/terraform/language/functions/templatefile
    docker-compose = templatefile("${path.module}/configs/${var.compose-type}.tpl.docker-compose.yaml", {
      DEVICE_NAME = local.device-name

      DEFAULT_USER = local.default-user

      POSTGRES_DB       = "my_db"
      POSTGRES_USER     = "my_user"
      POSTGRES_PASSWORD = "my_password"

      PGADMIN_DEFAULT_EMAIL    = "test@gmail.com"
      PGADMIN_DEFAULT_PASSWORD = "testpassword"
    })
    user-data = templatefile("${path.module}/configs/cloud-init.tpl.yaml", {
      DEFAULT_USER   = local.default-user
      SSH_PUBLIC_KEY = file(var.ssh-public-key-path)
      POSTGRES_INIT_SQL_QUERY = templatefile("${path.module}/configs/postgres/init.tpl.sql", {
        POSTGRES_USER     = "my_user"
        POSTGRES_PASSWORD = "my_password"
      })
    })
  }

}

# Создание зоны DNS
# https://yandex.cloud/ru/docs/compute/tutorials/bind-domain-vm/terraform
resource "yandex_dns_zone" "domain-zone" {
  name        = "ikemurami-domain-zone"
  description = "Create domain zone"

  zone   = "${var.domain-zone}."
  public = true
}

# data "yandex_dns_zone" "domain-zone" {
#   name = "domain-zone"
# }

# Создание ресурсной записи типа А
resource "yandex_dns_recordset" "record" {
  zone_id = yandex_dns_zone.domain-zone.id
  name    = "${local.subdomain-name}.${var.domain-zone}."
  type    = "A"
  ttl     = 200
  data    = ["${yandex_compute_instance.instance.network_interface.0.nat_ip_address}"]
}

output "external_ip" {
  value = yandex_compute_instance.instance.network_interface.0.nat_ip_address
}

output "external_domain" {
  value = "${local.subdomain-name}.${var.domain-zone}"
}
