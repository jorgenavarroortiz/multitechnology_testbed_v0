#!/usr/bin/env bash

NUM_UES=2
SMF_UE_SUBNET="10.1.1"
GW_LAST_BYTE="3"

# Configure namespace
echo "Preparing MPTCP namespace"
MPTCPNS="MPTCPns"
EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
sudo ip netns add ${MPTCPNS}

# Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
for i in $(seq 1 $NUM_UES)
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
   NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"            # Network address
   echo "NET_IP_MPTCP${i}: ${NET_IP_MPTCP}"
   GW_MPTCP=$SMF_UE_SUBNET"."$GW_LAST_BYTE       # Gateway address (assumed at ${SMF_UE_SUBNET}.222)
   echo "GW_MPTCP${i}: ${GW_MPTCP}"
   $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
   $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400   # done to avoid fragmentation which breaks ovpn setup
done
