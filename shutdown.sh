source $HOME/.config/snxvpn/snx.env
CONTAINER_IP=$(docker inspect snxvpn --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

for route in $SNX_ROUTES; do
  sudo ip route del $route via $CONTAINER_IP
done

docker kill snxvpn
docker rm snxvpn
