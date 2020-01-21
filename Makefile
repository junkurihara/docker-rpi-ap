# Makefile
# https://qiita.com/mt08/items/b6356b8e967f5c121bf1  

SSID=Pi4-AP
PASS=raspberry
DAEMON=1
CH=36

DOCKER_IMAGE_NAME=jqtype/rpi-ap
DOCKER_IMAGE_VERSION=2020.0121.1
DOCKER_CONTAINER_NAME=rpi-ap

ifeq ($(DAEMON),1)
	DOCKER_OPT=-d
else
	DOCKER_OPT=-it
endif

all:


run:
	make stop
	docker run ${DOCKER_OPT} --name ${DOCKER_CONTAINER_NAME} --rm -e AP_SSID=${SSID} -e AP_WPA_PASSPHRASE=${PASS} -e AP_CHANNEL=${CH} --net=host --privileged ${DOCKER_IMAGE_NAME}

bash:
	docker exec -it ${DOCKER_CONTAINER_NAME} /bin/bash

stop:
	docker ps -a | grep "${DOCKER_IMAGE_NAME}" | cut -f 1 -d' ' | xargs -P1 -i docker stop -t 0 {}

status:
	docker ps -a 

build: Dockerfile rpi-ap_start.sh
	docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} ${DOCKER_IMAGE_NAME}:latest

clean:
	# Stop container(s)
	docker ps -a | grep "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" | cut -f 1 -d' ' | xargs -P1 -i docker stop -t 0 {}
	# Remove container(s)
	docker ps -a | grep "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" | cut -f 1 -d' ' | xargs -P1 -i docker rm {}
	# Remove Image(s)
	docker images "${DOCKER_IMAGE_NAME}" | sed 's/\s\+/ /g' | tail -n +2 | cut -f 2 -d ' '| xargs -P1 -i docker rmi ${DOCKER_IMAGE_NAME}:{}


.PHONY: all run stop status build clean
