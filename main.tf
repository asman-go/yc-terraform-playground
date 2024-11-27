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

# Security group

resource "yandex_vpc_security_group" "playground-security-group" {
    # https://yandex.cloud/ru/docs/vpc/concepts/security-groups
  name = "plauground-security-group"
  network_id = yandex_vpc_network.asman-network.id
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
    description = "Allow HTTP"
    protocol = "TCP"
    port = 8081
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    protocol = "TCP"
    port = 8082
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

  provider       = yandex.with-project-info

  depends_on = [ yandex_vpc_network.asman-network ]
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
  image-url          = "cr.yandex/crpnqn6joccbivjbkb27/nginx-playground:1.4"
  network-name = yandex_vpc_network.asman-network.name

  providers = {
    yandex = yandex.with-project-info
  }

  depends_on = [yandex_iam_service_account.docker-image-creator]
}

module "vm-instance-docker" {
  source = "./vm-instance-docker"
  zone = local.zone
  # network-name = yandex_vpc_network.asman-network.name
  subnet-name  = yandex_vpc_subnet.asman-subnet-a.name
  service-account-id = yandex_iam_service_account.docker-image-creator.id
  security-group-id = yandex_vpc_security_group.playground-security-group.id

  providers = {
    yandex = yandex.with-project-info
  }

  depends_on = [
    yandex_iam_service_account.docker-image-creator,
    yandex_vpc_subnet.asman-subnet-a
  ]
}

module "vm-instance-docker-compose" {
  source = "./vm-instance-docker-compose"
  zone = local.zone
  subnet-name  = yandex_vpc_subnet.asman-subnet-a.name
  service-account-id = yandex_iam_service_account.docker-image-creator.id
  security-group-id = yandex_vpc_security_group.playground-security-group.id

  providers = {
    yandex = yandex.with-project-info
  }

  depends_on = [
    yandex_iam_service_account.docker-image-creator,
    yandex_vpc_subnet.asman-subnet-a
  ]
}