#!/bin/bash
# Delete previous configuration
sudo ovs-vsctl del-br cpe-br

# OVS switch
sudo ovs-vsctl add-br cpe-br
sudo ovs-vsctl add-port cpe-br eth4

# Configure interfaces
sudo ifconfig eth4 0
#sudo ifconfig eth1 down
#sudo ifconfig eth2 down
#sudo ifconfig eth3 down
#sudo ifconfig eth5 down
sudo ifconfig cpe-br 192.168.56.2/24

# Configure routes
#sudo route add default gw 192.168.56.1

# Flow entries
#sudo ovs-ofctl add-flow cpe-br in_port=eth4,actions=LOCAL -OOpenFlow13
#sudo ovs-ofctl add-flow cpe-br in_port=LOCAL,actions=output:eth4 -OOpenFlow13
