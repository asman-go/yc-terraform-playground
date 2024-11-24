locals {
  cloud_name  = "ikemurami-cloud"
  folder_name = "asman-debug"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

data "yandex_resourcemanager_cloud" "cloud" {
  name = local.cloud_name
}

data "yandex_resourcemanager_folder" "folder" {
  cloud_id = data.yandex_resourcemanager_cloud.cloud.id
  name     = local.folder_name
}

provider "yandex" {
  alias     = "with-project-info"
  cloud_id  = data.yandex_resourcemanager_cloud.cloud.id
  folder_id = data.yandex_resourcemanager_folder.folder.id
}
