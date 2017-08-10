

APP_NAME		= matinale-tech
VERSION 		:= $(shell git rev-parse --short HEAD)
ARCH			= amd64
OS				= linux
LD_FLAGS		= -ldflags "-X main.version=$(VERSION)"
IMAGE_TAG		= 1
IMAGE_NAME 		= matinale-tech
CONTAINER_NAME 	= matinale-tech
REGISTRY		= 808017386784.dkr.ecr.eu-west-1.amazonaws.com
PORTS 			= -p 8080:80

all: $(APP_NAME)

$(APP_NAME):
	@echo "Building application for localhost"
	go build $(LD_FLAGS) -o $(APP_NAME)

test: all
	@echo "Running tests..."
	go test -cover -race ./...

clean:
	rm -f $(APP_NAME)

re: clean all

dpush:
	@echo "Pushing the image to remote repository..."
	docker push $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo "  all                                build the application with defaut configuration"
	@echo "  clean                              delete the application and the image"
	@echo "  re                               	run clean and all target one after another"
	@echo "  dpush                              push the built docker image to the remote registry"
	@echo "  drebuild                           rebuilds the image from scratch without using any cached layers"
	@echo "  drun                               run the built docker image"
	@echo "  drestart                           restarts the docker image"
	@echo "  dbash                              starts bash inside a running container."

dbuild:
	@echo "Building docker image..."
	GOARCH=$(ARCH) GOOS=$(OS) go build $(LD_FLAGS) -o $(APP_NAME)
	docker build -f Dockerfile -t "$(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)" .

dclean:
	@echo "Cleaning docker image..."
	-docker rmi $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

drebuild:
	@echo "Rebuilding docker image..."
	docker build --no-cache=true -f Dockerfile -t "$(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)" .

drun:
	make dstop
	make dbuild
	docker run --rm $(PORTS) $(HOSTS) -it --name ${CONTAINER_NAME} $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

drestart: drun

dstart:
	make dstop
	make dbuild
	docker run -d $(PORTS) $(HOSTS) --name ${CONTAINER_NAME} $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

dbash:
	docker exec -it $(CONTAINER_NAME) /bin/sh

dstop:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
