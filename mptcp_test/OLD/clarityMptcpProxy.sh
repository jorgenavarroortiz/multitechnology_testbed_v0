#!/usr/bin/env bash
#
# This script is used to setup the MPTCP proxy
#
# Authors: Daniel Camps (daniel.camps@i2cat.net), Jorge Navarro (jorgenavarro@ugr.es)
# Copyright: i2CAT, UGR

# CONFIGURATION (*** TO BE INCLUDED AS SCRIPT PARAMETERS ***)
PATHMANAGER=fullmesh   # default, fullmesh, ndiffports, binder
SCHEDULER=default      # default, roundrobin, redundant
CONGESTIONCONTROL=olia # reno cubic lia olia wvegas balia mctcpdesync
ETH2STATE=on           # on, off, backup

GlobalEth="eth1"
GlobalGW="60.60.0.102"
GWeth1=GlobalGW

# Just to make sure that the configuration is correct
  # Add data network IP address to eth1
DN_IP="60.60.0.101"
sudo ifconfig eth1 $DN_IP"/24" up
  # Add static route to reach MPTCP UEs
sudo ip route add "10.0.1/24" via 60.60.0.102 dev eth1

##############################
# Environment configuration
##############################

# Check OS
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
    echo "This Linux version is too old: $OS:$VER, we don't support!"
    exit 1
fi

#sudo -v
#if [ $? == 1 ]
#then
#    echo "Error: root permission is needed!"
#    exit 1
#fi

####################
# Configure MPTCP path manager
####################
# eth1 information
IPeth1=`ifconfig eth1 | grep inet | tr -s ' ' | cut -d' ' -f 3`
if [[ $DEBUG -eq 1 ]]; then echo "[DEBUG] IPeth1:   ${IPeth1}"; fi
netmasketh1bits=`ip -o -f inet addr show eth1 | tr -s ' ' | cut -d' ' -f 4 | cut -d'/' -f 2`
netmasketh1=`ifconfig eth1 | grep inet | tr -s ' ' | cut -d' ' -f 5`
IFS=. read -r i1 i2 i3 i4 <<< $IPeth1
IFS=. read -r m1 m2 m3 m4 <<< $netmasketh1
NETeth1=`printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))"`
NETeth1=`echo ${NETeth1}/${netmasketh1bits}`

# Show MPTCP version
echo ""; echo "[INFO] Show version and configuration parameters"
sudo dmesg | grep MPTCP

# Disable interfaces for MPTCP (eth0 = NAT connection, eth3 = connection with host OS)
sudo ip link set dev eth0 multipath off
sudo ip link set dev eth2 multipath off

# Normal interface
sudo ip link set dev eth1 multipath on

# Modify tunable variables
sudo sysctl -w net.mptcp.mptcp_enabled=1     # Default 1
sudo sysctl -w net.mptcp.mptcp_checksum=1    # Default 1 (both sides have to be 0 in order to disable this)
sudo sysctl -w net.mptcp.mptcp_syn_retries=3 # Specifies how often we retransmit a SYN with the MP_CAPABLE-option. Default 3
sudo sysctl -w net.mptcp.mptcp_path_manager=$PATHMANAGER
sudo sysctl -w net.mptcp.mptcp_scheduler=$SCHEDULER

# Congestion control
sudo sysctl -w net.ipv4.tcp_congestion_control=$CONGESTIONCONTROL

# Remove previous rules
for i in {32700..32765}; do sudo ip rule del pref $i 2>/dev/null ; done

# Create two different routing tables
sudo ip rule add from $IPeth1 table 1 2> /dev/null
#sudo ip rule add from $IPeth2 table 2 2> /dev/null
# Configure the two different routing tables
sudo ip route add $NETeth1 dev eth1 scope link table 1 2> /dev/null
sudo ip route add default via $GWeth1 dev eth1 table 1 2> /dev/null
#sudo ip route add $NETeth2 dev eth2 scope link table 2 2> /dev/null
#sudo ip route add default via $GWeth2 dev eth2 table 2 2> /dev/null
# Default route for normal internet
sudo ip route add default scope global nexthop via $GlobalGW dev $GlobalEth 2> /dev/null
# Show routing tables
echo ""; echo "[INFO] Show rules"
sudo ip rule show
echo ""; echo "[INFO] Show routes"
sudo ip route
echo ""; echo "[INFO] Show routing table 1"
sudo ip route show table 1
#echo ""; echo "[INFO] Show routing table 2"
#sudo ip route show table 2

# OVPN
cd $HOME/free5gc/ovpn-config-proxy
sudo openvpn ovpn-server.conf &

sleep 5
TAPIF=`ip link show | grep tap -m 1 | cut -d ":" -f 2 | tr -d " "`
sudo ip link set dev ${TAPIF} multipath off

# TODO: Bridge tap0 with exit interface
