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

# IAM

resource "yandex_iam_service_account" "docker-image-creator" {
  name        = "docker-image-creator"
  description = "Сервисный аккаунт для загрузки контейнеров в docker registry"

  provider = yandex.with-project-info
}

resource "yandex_resourcemanager_folder_iam_binding" "image-puller" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  role      = "container-registry.images.puller"
  members   = ["serviceAccount:${yandex_iam_service_account.docker-image-creator.id}"]

  provider = yandex.with-project-info
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

module "serverless-container" {
  source = "./serverless-container"

  service-account-id = yandex_iam_service_account.docker-image-creator.id
  image-url          = "cr.yandex/crpnqn6joccbivjbkb27/nginx-playground:1.3"
  network-name = yandex_vpc_network.asman-network.name

  providers = {
    yandex = yandex.with-project-info
  }

  depends_on = [yandex_iam_service_account.docker-image-creator]
}
