# snx as a container

First release, only supports login/password.


## Build

```
docker build -t clook/snxvpn .
```

## Usage

### Configuration

Create a config file:

```
read -s SNX_PASSWORD

mkdir ~/.config/snxvpn
cat > ~/.config/snxvpn/snx.env << EOF
SNX_SERVER=<vpn_gateway_hostname>
SNX_USER=<vpn_user>
SNX_PASSWORD=$SNX_PASSWORD
SNX_ROUTES="10.x.y.0/24"
EOF
chmod 600 ~/.config/snxvpn/snx.env
```

### Launch

```
./launch.sh
```

Needed routes (filled as `SNX_ROUTES`) will be created on host to reach the container.

### Clean-up

When finished, the following script will remove routes and shutdown the container.

```
./shutdown.sh
```

## TODO

Add dnsmasq configuration to forward only domain-specific request to the DNS server.

## References

Heavily inspired from https://github.com/Kedu-SCCL/docker-snx-checkpoint-vpn
