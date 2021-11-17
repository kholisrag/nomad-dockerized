IMAGE_NAME=nomad
BUILDX_BUILDER_NAME="nomad-buildx-builder"
BUILDX_TARGETPLATFORM="linux/amd64,linux/arm64"

check:
	@which docker
	test -n "$(NOMAD_VERSION)"

prepare:
	make check
	$(eval export BUILDX_BUILDER_CHECK=$(shell docker buildx ls | grep $(BUILDX_BUILDER_NAME) | head -n 1 | awk '{print $$1}'))
	if [ "$(BUILDX_BUILDER_CHECK)" = "$(BUILDX_BUILDER_NAME)" ]; then \
		echo "Docker Buildx Builder Found..."; \
		echo $(BUILDX_BUILDER_CHECK); \
	else \
		echo "Docker Buildx Builder Not Found, Creating..."; \
		echo $(BUILDX_BUILDER_CHECK); \
		docker buildx create --name $(BUILDX_BUILDER_NAME) --use; \
	fi

build:
	make prepare
	docker buildx build . \
		--build-arg NOMAD_VERSION=$(NOMAD_VERSION) \
		--platform $(BUILDX_TARGETPLATFORM) \
		--tag $(IMAGE_NAME):latest \
		--tag $(IMAGE_NAME):$(NOMAD_VERSION) \
		-o type=docker

login:
	test -n "$(DOCKER_USERNAME)"
	test -n "$(DOCKER_PASSWORD)"
	docker login --username ${DOCKER_USERNAME} --password ${DOCKER_PASSWORD}

release:
	make prepare
	make login
	docker buildx build . \
		--build-arg NOMAD_VERSION=$(NOMAD_VERSION) \
		--platform $(BUILDX_TARGETPLATFORM) \
		--tag $(DOCKER_USERNAME)/$(IMAGE_NAME):latest \
		--tag $(DOCKER_USERNAME)/$(IMAGE_NAME):$(NOMAD_VERSION) \
		--push

clean:
	docker buildx rm $(BUILDX_BUILDER_NAME)
