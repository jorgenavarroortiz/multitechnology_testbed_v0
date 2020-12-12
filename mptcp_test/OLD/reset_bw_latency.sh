#!/bin/bash

# Clean previous rules
echo "Cleaning rules (latency and bandwidth) for eth1"
sudo tc qdisc del dev eth1 root 2> /dev/null
echo "Cleaning rules (latency and bandwidth) for eth2"
sudo tc qdisc del dev eth2 root 2> /dev/null

# Show rules
#sudo tc qdisc show dev eth1
#sudo tc qdisc show dev eth2

