#!/usr/bin/env bash
#
# This script is used to setup a 5GClarity UE with 2 namespaces representing the WiFi and LiFi interfaces and one MPTCP namesapce to aggregate traffic over the 2 access networks
#
# Authors: Daniel Camps (daniel.camps@i2cat.net), Jorge Navarro (jorgenavarro@ugr.es)
# Copyright: i2CAT, University of Granada

GOPATH=$HOME/go
SMF_UE_SUBNET="10.1.1"

####################
# Configure MPTCP path manager
####################

# Configure namespace
echo "Preparing MPTCP namespace"
MPTCPNS="MPTCPns"
EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
sudo ip netns add ${MPTCPNS}

# Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
for i in 1 2 #$(seq 1 $NUM_UES)
do
   echo ""
   echo "Connecting MPTCP namespace to UE "$i
   VETH_MPTCP="v_mp_"$i
   VETH_MPTCP_H="v_mph_"$i
   sudo ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H
   sudo ifconfig "eth"$i 0.0.0.0 up
   sudo brctl addbr "brmptcp_"$i
   sudo brctl addif "brmptcp_"$i "eth"$i
   sudo brctl addif "brmptcp_"$i $VETH_MPTCP_H
   sudo ip link set $VETH_MPTCP_H up
   sudo ip link set "brmptcp_"$i up
   sudo ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
   $EXEC_MPTCPNS ip link set $VETH_MPTCP up
   IP_MPTCP=$SMF_UE_SUBNET"."$i"/24"
   IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
   $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
   $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400   # done to avoid fragmentation which breaks ovpn setup

   # Path active for MPTCP
   $EXEC_MPTCPNS ip link set dev $VETH_MPTCP multipath on

   # Create a different routing table for each interface
   $EXEC_MPTCPNS ip rule add from $VETH_MPTCP table $i 2> /dev/null
   # Configure the routing table
   $EXEC_MPTCPNS ip route add $NET_IP_MPTCP dev $VETH_MPTCP scope link table $i 2> /dev/null
   $EXEC_MPTCPNS ip route add default via $GW_MPTCP dev $VETH_MPTCP table $i 2> /dev/null
done

$EXEC_MPTCPNS route add -net 60.60.0.0/24 gw 10.1.1.222
