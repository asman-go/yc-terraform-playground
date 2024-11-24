data "yandex_vpc_network" "asman-network" {
  name = var.network-name
}

data "yandex_vpc_subnet" "asman-subnet-a" {
  name = var.subnet-name
}

resource "yandex_mdb_postgresql_cluster" "postgres-cluster" {
    # Создается минут 20, стоит ~2500 руб/мес
  # https://terraform-provider.yandexcloud.net/resources/mdb_postgresql_cluster.html
  # https://yandex.cloud/ru/docs/managed-postgresql/operations/cluster-create
  name        = "postgres-cluster"
  description = "Managed PostgreSQL"
  network_id  = data.yandex_vpc_network.asman-network.id
  environment = "PRESTABLE"
  # deletion_protection = true

  config {
    version = 17 # postgresql 17
    resources {
      # https://yandex.cloud/ru/docs/managed-postgresql/concepts/instance-types
      resource_preset_id = "b2.medium"
      disk_type_id       = "network-hdd"
      disk_size          = "15"
    }
    postgresql_config = {
      # https://yandex.cloud/en/docs/managed-postgresql/concepts/settings-list
    }
    access {
      # from Datalens (https://cloud.yandex.com/services/datalens)
      # data_lens = true

      # SQL Queries from the management console
      # https://cloud.yandex.com/docs/managed-postgresql/operations/web-sql-query
      web_sql = true
    }
  }
  maintenance_window {
    type = "ANYTIME"
  }
  # 1 host
  host {
    name      = "postgres-host"
    zone      = var.zone
    subnet_id = data.yandex_vpc_subnet.asman-subnet-a.id
  }

}

resource "yandex_mdb_postgresql_user" "postgres-user" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres-cluster.id
  name       = "postgres-user"
  password   = "postgres-password"
}

resource "yandex_mdb_postgresql_database" "postgres-db" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres-cluster.id
  name       = "postgres-db"
  owner      = yandex_mdb_postgresql_user.postgres-user.name
}
