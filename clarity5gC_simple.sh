#!/bin/bash

# Assign IP addresses to the network interfaces
sudo ifconfig eth1 10.0.1.3/24
sudo ifconfig eth2 60.60.0.102/24

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
