locals {
  zone = "ru-central1-a"
}

resource "yandex_vpc_network" "asman-network" {
  name        = "asman-network"
  description = "VPC network name"
  provider    = yandex.with-project-info
}

resource "yandex_vpc_subnet" "asman-subnet-a" {
  name           = "asman-subnet-a"
  network_id     = yandex_vpc_network.asman-network.id
  zone           = local.zone
  v4_cidr_blocks = ["10.5.0.0/24"]
  provider       = yandex.with-project-info
}


# Modules

module "postgres-cluster" {
  source       = "./postgres"
  network-name = yandex_vpc_network.asman-network.name
  subnet-name  = yandex_vpc_subnet.asman-subnet-a.name
  zone         = local.zone

  providers = {
    yandex = yandex.with-project-info
  }

  depends_on = [
    yandex_vpc_network.asman-network,
    yandex_vpc_subnet.asman-subnet-a
  ]
}
