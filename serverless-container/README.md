# Как проверить

**Важно**: чтобы ваш докер контейнер запустился в serverless контейнере, он должен выставлять свой порт из переменной окружения `PORT`! 

```
curl --header "Authorization: Bearer $(yc iam create-token)" https://<container-id>.containers.yandexcloud.net/index.html
```
