SHELL := /bin/bash # to enable source command in run_app

MODULE=weevenetwork/dht-sensor-simulator
VERSION_NAME=v1.0.1

install_dev:
	python3 -m pip install -r requirements_dev.txt
.phony: install_dev

lint:
	black src/
	flake8 src/
.phony: lint

run_app:
	set -a && source .env && set +a && python src/main.py
.phony: run_app

create_image:
	docker build -t ${MODULE}:${VERSION_NAME} . -f docker/Dockerfile
.phony: create_image

run_image:
	docker run -p 80:80 --rm --env-file=./.env ${MODULE}:${VERSION_NAME}
.phony: run_image

run_docker_compose:
	docker-compose -f docker/docker-compose.yml up
.phony: run_docker_compose

stop_docker_compose:
	docker-compose -f docker/docker-compose.yml down
.phony: stop_docker_compose

run_test:
	docker-compose -f test/docker-compose.test.yml up
.phony: run_test

stop_test:
	docker-compose -f test/docker-compose.test.yml down
.phony: stop_test

push_latest:
	docker image push ${MODULE}:${VERSION_NAME}
.phony: push_latest

create_and_push_multi_platform:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7 -t ${MODULE}:${VERSION_NAME} --push . -f docker/Dockerfile
.phony: create_and_push_multi_platform

run_listener:
	docker run --rm -p 8000:8000 \
	-e PORT=8000 \
	-e LOG_HTTP_BODY=true \
	-e LOG_HTTP_HEADERS=true \
	--name listener \
	jmalloc/echo-server
.phony: run_listener
