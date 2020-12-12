#!/usr/bin/env bash
#
# This script is used to setup the MPTCP proxy
#
# Author: Daniel Camps (daniel.camps@i2cat.net)
# Copyright: i2CAT

####################
# Configure MPTCP path manager
####################
sudo sysctl -w net.mptcp.mptcp_path_manager=fullmesh
# Loading roundrobin as kernel module otherwise it is not available for selection through sysctl
LOADED=$(lsmod | grep mptcp_rr)
if [ "$LOADED" == "" ]; then
        sudo insmod /lib/modules/4.19.126/kernel/net/mptcp/mptcp_rr.ko
fi


# Add data network IP address to eth1
DN_IP="60.60.0.101"
sudo ifconfig eth1 $DN_IP"/24" up

# Add static route to reach MPTCP UEs
sudo ip route add "10.0.1/24" via 60.60.0.102 dev eth1
#sudo ip route add "10.1.1/24" via 60.60.0.102 dev eth1
#sudo ip route add "10.1.2/24" via 60.60.0.102 dev eth1
#sudo ip route add "10.1.3/24" via 60.60.0.102 dev eth1

# Launch openvpn server
echo ""
echo "######################"
echo "# Launching OVPN server"
echo ""
cd ovpn-config-proxy/
openvpn ovpn-server.conf &

# TODO: Bridge tap0 with exit interface
