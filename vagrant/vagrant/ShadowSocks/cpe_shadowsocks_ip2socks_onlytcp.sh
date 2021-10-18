#!/bin/bash

# Default route
sudo route del default
sudo route add default gw 10.1.1.4

# ShadowSocks local server
sudo kill -9 `pgrep ss-local`
sudo ss-local -c /home/vagrant/config-cpe.json -f ~/ss-local.pid
sudo sysctl -w net.ipv4.ip_forward=1
sudo route del default gw 10.1.1.4

# TAP interface (ip2socks)
cd ip2socks
sudo ./ip2socks --config=../config-cpe-ip2socks.yml
