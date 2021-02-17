#!/bin/bash

source $HOME/.config/snxvpn/snx.env
docker run --name=snxvpn --cap-add=NET_ADMIN -v /lib/modules:/lib/modules:ro -e SNX_SERVER=$SNX_SERVER -e SNX_USER=$SNX_USER -e SNX_PASSWORD="$SNX_PASSWORD" -d -t clook/snxvpn

until [ "`/usr/bin/docker inspect -f {{.State.Running}} snxvpn`"=="true" ]; do
    sleep 0.1;
done;

# DNS and services
CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' snxvpn)
for route in $SNX_ROUTES; do
  sudo ip route add $route via $CONTAINER_IP
done
