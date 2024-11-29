# Terraform Playground

Учусь:

- Поднимать самую дешевую Postgres
- Поднимать serverless container из образа
- Поднимать VM instance из docker-образа
- Поднимать VM instance из docker-compose файла
- [-] Поднимать ALB: https://yandex.cloud/ru/docs/certificate-manager/tutorials/tls-termination/terraform
- Подключать публичный IP
- Подключать домен
- Настраивать сертификаты: https://yandex.cloud/en/docs/certificate-manager/tf-ref

Сначала собираем контейнер (каталог container-example), затем запускаем наш терраформ:

```
export YC_TOKEN="$(yc iam create-token --folder-id b1gr7b87128mt4levqg1)
terraform init
terraform get -update=true
terraform fmt
terraform validate
terraform plan
terraform apply
```
