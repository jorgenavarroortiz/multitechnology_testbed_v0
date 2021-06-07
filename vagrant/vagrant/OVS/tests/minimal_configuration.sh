#!/bin/bash
# Delete previous configuration
sudo ovs-vsctl del-br cpe-br

# OVS switch
sudo ovs-vsctl add-br cpe-br
sudo ovs-vsctl add-port cpe-br eth0

# Configure interfaces
sudo ifconfig eth0 0
sudo ifconfig cpe-br 10.0.2.15/24
sudo ifconfig eth1 down
sudo ifconfig eth2 down
sudo ifconfig eth3 down
sudo ifconfig eth4 down
sudo ifconfig eth5 down

# Configure routes
sudo route add default gw 10.0.2.2

# Flow entries
#sudo ovs-ofctl add-flow cpe-br in_port=eth0,actions=LOCAL -OOpenFlow13
#sudo ovs-ofctl add-flow cpe-br in_port=LOCAL,actions=output:eth0 -OOpenFlow13

