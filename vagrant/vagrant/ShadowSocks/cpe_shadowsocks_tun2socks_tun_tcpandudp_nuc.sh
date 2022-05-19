#!/bin/bash

USER='jorge'

# Default route
#sudo route del default
#sudo route add default gw 10.1.1.4

# ShadowSocks local server
sudo kill -9 `pgrep ss-local`
sudo ss-local -c /home/${USER}/vagrant/ShadowSocks/config-cpe.json -f ~/ss-local.pid
sudo sysctl -w net.ipv4.ip_forward=1
sudo route del default gw 10.1.1.4

## TUN interface (tun2socks)
sudo ip tuntap add dev tun0 mode tun user ${USER}
##sudo ifconfig tun0 mtu 1400 # TO BE CHECK IF IT IS NEEDED
sudo ifconfig tun0 10.0.0.1 netmask 255.255.255.0
sudo ip r a 10.1.1.4 via 10.1.1.4
sudo ip r a default via 10.0.0.2 metric 10
echo "Starting tun2socks connection..."
sudo badvpn-tun2socks --tundev tun0 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 127.0.0.1:1080 --socks5-udp --loglevel none
