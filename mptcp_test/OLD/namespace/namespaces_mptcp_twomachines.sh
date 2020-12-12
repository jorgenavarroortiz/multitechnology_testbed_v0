#!/usr/bin/env bash

NUM_UES=2
SMF_UE_SUBNET="10.1.1"
GW_LAST_BYTE="3"

PATHMANAGER=fullmesh   # default, fullmesh, ndiffports, binder
SCHEDULER=default      # default, roundrobin, redundant
CONGESTIONCONTROL=olia # reno cubic lia olia wvegas balia mctcpdesync

####################
# Configure MPTCP path manager
####################

# Show MPTCP version
echo ""; echo "[INFO] Show version and configuration parameters"
sudo dmesg | grep MPTCP

  sudo ip link set dev eth0 multipath off
  sudo ip link set dev eth3 multipath off

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

  #sudo ip route add default scope global nexthop via $GlobalGW dev $GlobalEth 2> /dev/null

# Configure namespace
echo "Preparing MPTCP namespace"
MPTCPNS="MPTCPns"
EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"

# Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
for i in $(seq 1 $NUM_UES)
do
  VETH_MPTCP="v_mp_"$i
  VETH_MPTCP_H="v_mph_"$i
  IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
  NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"
  GW_MPTCP=$SMF_UE_SUBNET"."$GW_LAST_BYTE
  echo "Information for interface ${i}..."
  echo "VETH_MPTCP: ${VETH_MPTCP}"
  echo "VETH_MPTCP_H: ${VETH_MPTCP_H}"
  echo "NET_IP_MPTCP: ${NET_IP_MPTCP}"
  echo "GW_MPTCP: ${GW_MPTCP}"

  # Create routing tables for each interface
  $EXEC_MPTCPNS ip rule add from $IP_MPTCP_SIMPLE table $i #2> /dev/null
  $EXEC_MPTCPNS ip route add $NET_IP_MPTCP dev $VETH_MPTCP scope link table $i #2> /dev/null
  $EXEC_MPTCPNS ip route add default via $GW_MPTCP dev $VETH_MPTCP table $i #2> /dev/null

  # Default route for normal internet
#  if [[ $i == 1 ]]; then
#    sudo ip route add default scope global nexthop via $GW_MPTCP dev $VETH_MPTCP $i> /dev/null
#  fi

  sudo ip link set dev eth$i multipath on
  sudo ip link set dev $VETH_MPTCP_H multipath on
  $EXEC_MPTCPNS ip link set dev $VETH_MPTCP multipath on
done

  # Show routing tables
  echo ""; echo "[INFO] Show rules"
  $EXEC_MPTCPNS ip rule show
  echo ""; echo "[INFO] Show routes"
  $EXEC_MPTCPNS ip route
  echo ""; echo "[INFO] Show routing table 1"
  $EXEC_MPTCPNS ip route show table 1
  echo ""; echo "[INFO] Show routing table 2"
  $EXEC_MPTCPNS ip route show table 2
