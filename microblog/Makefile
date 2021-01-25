docker-login:
	@docker login --username AWS --password $(shell aws ecr get-login-password) "${AWS_ECR_REPO}"

docker-build: Dockerfile
	docker build -t "${AWS_ECR_REPO}:latest" -t "${AWS_ECR_REPO}:$(shell git rev-parse --short HEAD)" .

docker-push: Dockerfile
	docker push "${AWS_ECR_REPO}:latest"

docker-remove:
	docker image rm "${AWS_ECR_REPO}:latest"

all: docker-login docker-build docker-push
