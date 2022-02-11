#!/bin/bash

sudo modprobe tun

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

echo Waiting for VPN tunnel to be up, please check your MFA device if necessary.

publicis_nameserver=""

for i in $(seq 10); do
  publicis_nameserver=$(docker logs snxvpn | grep "^DNS Server" | awk '{ print $4 }')
  if [ -n "$publicis_nameserver" ]; then
    break
  fi
  sleep 5
done

if [ -z "$publicis_nameserver" ]; then
  echo Timeout waiting for VPN tunnel
  exit 1
fi

echo Got Publicis nameserver: $publicis_nameserver
default_nameservers=$(grep "^nameserver [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$" /etc/resolv.conf | awk '{ print $2 }' | sed 's/\n/ /')

docker run -d --net=host --name=dnsmasq-proxy -e SPECIFIC_NAMESERVERS="publicisgroupe.net:$publicis_nameserver" -e DEFAULT_NAMESERVERS="$default_nameservers" elafarge/dnsmasq-proxy
echo "nameserver 127.0.0.1" | sudo resolvconf -a tun0
