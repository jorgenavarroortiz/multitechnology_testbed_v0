#!/bin/bash
# Delete previous configuration
sudo ovs-vsctl del-br vpn-br

# OVS switch
sudo ovs-vsctl add-br vpn-br
sudo ovs-vsctl add-port vpn-br tap0
sudo ovs-vsctl add-port vpn-br eth4

# Configure interfaces
sudo ifconfig tap0 0.0.0.0 promisc up
sudo ifconfig eth4 0.0.0.0 promisc up
sudo ifconfig vpn-br 10.8.0.2/24

# Configure routes
#sudo route add default gw 10.0.2.2
#sudo route add -net 192.168.56.0/24 dev vpn-br
### Remember to include the corresponding route in the other machine, e.g.:
#sudo route add -net 10.8.0.0/24 dev vboxnet0
### Better change vboxnet0 in the host to have IP 10.8.0.33, so all are in the same network (and we do not have to add routes)

# Flow entries
#sudo ovs-ofctl add-flow cpe-br in_port=eth0,actions=LOCAL -OOpenFlow13
#sudo ovs-ofctl add-flow cpe-br in_port=LOCAL,actions=output:eth0 -OOpenFlow13

# Show information
sudo ovs-vsctl show
echo "IMPORTANT: Remember to configure host's vboxnet0 using IP 10.8.0.33/24"
echo "           and make sure that all VM's interfaces are on promiscuous mode"
