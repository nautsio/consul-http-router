NAME:=$(shell basename $(PWD))
IMAGE=cargonauts/$(NAME)
REVISION:=$(shell git rev-parse --short HEAD)

.PHONY: pre-build docker-build post-build build release showrev

default: build

showrev:
	@echo $(REVISION)

showname:
	@echo $(NAME)

pre-build:

post-build:

docker-build:
	docker build --no-cache --force-rm -t $(IMAGE):$(REVISION) .

build: pre-build docker-build docker-tag post-build

no-outstanding-changes:
	@[ -z "$$(git status -s .)" ] || (echo "outstanding changes" ; git status -s . && exit 1)

docker-tag:
	docker tag -f $(IMAGE):$(REVISION) $(IMAGE):latest
	@echo $(IMAGE):$(REVISION)

docker-push:
	docker push $(IMAGE):$(REVISION)
	docker push $(IMAGE):latest

release: build no-outstanding-changes docker-push
