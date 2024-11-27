data "yandex_vpc_network" "asman-network" {
  name = var.network-name
}

resource "yandex_serverless_container" "container" {
  # https://yandex.cloud/ru/docs/serverless-containers/operations/create
  name              = "serverless-container"
  description       = "Пробую поднять serverless контейнер"
  memory            = 256
  execution_timeout = "15s"
  cores             = 1
  core_fraction     = 30
  image {
    url = var.image-url
  }
  connectivity {
    network_id = data.yandex_vpc_network.asman-network.id
  }
  service_account_id = var.service-account-id
}