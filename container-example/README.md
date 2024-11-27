# Build and push the docker image to a docker registry

**Важно**: чтобы ваш докер контейнер запустился в serverless контейнере, он должен выставлять свой порт из переменной окружения `PORT`! 

1. Edit image registry link in the `Makefile` (`IMAGE_REGISTRY`)
2. Run:

```
$ make build
$ make push
```

3. Run locally

```
$ make up

or

$ docker compose build
$ docker compose up
```
