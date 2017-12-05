# sudo docker build -t mt08/rpi-ap .
# sudo docker run -it --rm --net=host --privileged mt08/rpi-ap

FROM resin/rpi-raspbian:stretch
LABEL maintainer="mt08 <mt08xx@users.noreply.github.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    hostapd isc-dhcp-server iptables iproute2 &&\
    mkdir -p /var/lib/dhcp/ && touch  /var/lib/dhcp/dhcpd.leases && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD rpi-ap_start.sh /bin/rpi-ap_start.sh

ENTRYPOINT [ "/bin/rpi-ap_start.sh" ]
