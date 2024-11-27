IMAGE_NAME = "nginx-playground"
IMAGE_VERSION = "1.4"

IMAGE_REGISTRY = "cr.yandex/crpnqn6joccbivjbkb27"

IMAGE_REPOSITORY = ${IMAGE_REGISTRY}/${IMAGE_NAME}
IMAGE_FULL_NAME = ${IMAGE_REPOSITORY}:${IMAGE_VERSION}


hello:
	@echo 'Build nginx docker image and push the image to a Docker registry'

build:
	@echo 'Build nginx docker image'
	@docker build -f Dockerfile -t ${IMAGE_FULL_NAME} .

up:
	@echo 'Start container locally: go to http://localhost:9015/index.html'
	@docker run --name ${IMAGE_NAME} -p 9015:8080 -e PORT=8080 ${IMAGE_FULL_NAME}

push:
	@echo 'Push the image to the docker registry'
	@docker push ${IMAGE_FULL_NAME}
