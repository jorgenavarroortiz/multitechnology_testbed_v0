#!/usr/bin/env bash
NUM_UES=2
SMF_UE_SUBNET="10.1.1"

for i in $(seq 1 $NUM_UES)
do
   sudo brctl addbr "brmptcp_"$i
   sudo ip link set "brmptcp_"$i up
done

# Configure namespace 1
NSNO=1
echo "Preparing MPTCP namespace ${NSNO}"
MPTCPNS="MPTCPns"${NSNO}
EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
sudo ip netns add ${MPTCPNS}

# Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
for i in $(seq 1 $NUM_UES)
do
   echo ""
   echo "Connecting MPTCP namespace ${NSNO} to UE $i"

   VETH_MPTCP="v${NSNO}_mp_"$i
   VETH_MPTCP_H="v${NSNO}_mph_"$i
   sudo ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H

   #sudo ifconfig "eth"$i 0.0.0.0 up
   #sudo brctl addif "brmptcp_"$i "eth"$i

   sudo brctl addif "brmptcp_"$i $VETH_MPTCP_H
   sudo ip link set $VETH_MPTCP_H up
   sudo ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
   $EXEC_MPTCPNS ip link set $VETH_MPTCP up

   IP_MPTCP=$SMF_UE_SUBNET"."$(( i+2*(NSNO-1) ))"/24"
   IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$(( i+2*(NSNO-1) ))
   NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"            # Network address
   echo "NET_IP_MPTCP${i}: ${NET_IP_MPTCP}"
   $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
   $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400   # done to avoid fragmentation which breaks ovpn setup
done

# Configure namespace 2
NSNO=2
echo "Preparing MPTCP namespace ${NSNO}"
MPTCPNS="MPTCPns"${NSNO}
EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
sudo ip netns add ${MPTCPNS}

# Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
for i in $(seq 1 $NUM_UES)
do
   echo ""
   echo "Connecting MPTCP namespace ${NSNO} to UE $i"

   VETH_MPTCP="v${NSNO}_mp_"$i
   VETH_MPTCP_H="v${NSNO}_mph_"$i
   sudo ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H

   #sudo ifconfig "eth"$i 0.0.0.0 up
   #sudo brctl addif "brmptcp_"$i "eth"$i

   sudo brctl addif "brmptcp_"$i $VETH_MPTCP_H
   sudo ip link set $VETH_MPTCP_H up
   sudo ip link set "brmptcp_"$i up
   sudo ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
   $EXEC_MPTCPNS ip link set $VETH_MPTCP up

   IP_MPTCP=$SMF_UE_SUBNET"."$(( i+2*(NSNO-1) ))"/24"
   IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$(( i+2*(NSNO-1) ))
   NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"            # Network address
   echo "NET_IP_MPTCP${i}: ${NET_IP_MPTCP}"
   $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
   $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400   # done to avoid fragmentation which breaks ovpn setup
done
