#!/bin/bash

USER='jorge'

# Default route
sudo route del default
sudo route add default gw 10.1.1.1

# TCP fast open
sudo sh -c 'echo 3 > /proc/sys/net/ipv4/tcp_fastopen'

# ShadowSocks server
sudo ss-server -c /home/${USER}/vagrant/ShadowSocks/config-proxy1.json -f ~/ss-server.pid #-v
