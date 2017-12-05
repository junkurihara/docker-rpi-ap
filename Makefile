# Makefile
#  mt08
#

SSID=RPi-AP
PASSWORD=password


DOCKER_IMAGE_NAME=mt08/rpi-ap
DOCKER_IMAGE_VERSION=2017.1204.1

all:


run:
	docker run -d --rm -e AP_SSID=${SSID} -e AP_WPA_PASSPHRASE=${PASSWORD} --net=host --privileged ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}
stop:
	docker ps -a | grep "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" | cut -f 1 -d' ' | xargs -P1 -i docker stop -t 0 {}
status:
	docker ps -a 
build: Dockerfile rpi-ap_start.sh
	docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .

clean:
	docker ps -a | grep "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" | cut -f 1 -d' ' | xargs -P1 -i docker stop {}
	docker ps -a | grep "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" | cut -f 1 -d' ' | xargs -P1 -i docker rm {}
	docker images "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" | tail -n +2
	docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}

