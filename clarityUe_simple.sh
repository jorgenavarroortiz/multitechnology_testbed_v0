#!/usr/bin/env bash
#
# This script is used to setup a 5GClarity UE with 2 namespaces representing the WiFi and LiFi interfaces and one MPTCP namesapce to aggregate traffic over the 2 access networks
#
# Author: Daniel Camps (daniel.camps@i2cat.net)
# Copyright: i2CAT
# Modified by Jorge Navarro-Ortiz (jorgenavarro@ugr.es)


#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 [-n <NUM_UEs>] [-m -P <path manager> -S <scheduler> -C <congestion control> -c <CWND limited>] [-s <SmfUeSubnet>] [-o <OvpnServerAddress>] [-h]" 1>&2;

  echo ""
  echo "E.g.: $0 -n 2 -m -P fullmesh -S default -C olia -s 10.0.1 -o 60.60.0.101"
  echo ""
  echo "       <path manager> ........... default, fullmesh, ndiffports, binder"
  echo "       <scheduler> .............. default, roundrobin, redundant"
  echo "       <congestion control> ..... reno, cubic, lia, olia, wvegas, balia, mctcpdesync"
  echo "       <CWND limited> ........... for roundrobin, whether the scheduler tries to fill the congestion window on all subflows (Y) or whether it prefers to leave open space in the congestion window (N) to achieve real round-robin (even if the subflows have very different capacities)"
  echo ""
  echo "       -h ....................... this help"
  exit 1;
}

# Default values
NUM_UES=2
MPTCP=True
PATHMANAGER="fullmesh"
SCHEDULER="default"
CONGESTIONCONTROL="olia"
CWNDLIMITED="Y"
SMF_UE_SUBNET="10.0.1"
OVPN=False
OVPN_SERVER_IP="60.60.0.101"

while getopts ":n:mP:S:C:c:s:o:h" o; do
  case "${o}" in
    n)
      NUM_UES=${OPTARG}
      n=1
      echo "NUM_UEs="$NUM_UES
      ;;
    m)
      MPTCP=True
      echo "MPTCP mode is enabled"
      ;;
    P)
      p=1
      PATHMANAGER=${OPTARG}
      echo "PATHMANAGER="$PATHMANAGER
      ;;
    S)
      s=1
      SCHEDULER=${OPTARG}
      echo "SCHEDULER="$SCHEDULER
      ;;
    C)
      c=1
      CONGESTIONCONTROL=${OPTARG}
      echo "CONGESTIONCONTROL="${OPTARG}
      ;;
    c)
      w=1
      CWNDLIMITED=${OPTARG}
      echo "CWNDLIMITED="${OPTARG}
      ;;
    s)
      t=1
      SMF_UE_SUBNET=${OPTARG}
      echo "UE Subnet configured in SMF="$SMF_UE_SUBNET
      ;;
    o)
      OVPN=True
      OVPN_SERVER_IP=${OPTARG}
      echo "MPTCP namespace will launch OpenVPN tunnel"
      ;;
    h)
      h=1
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [[ $h == 1 ]]; then
    usage
fi

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

# Check if it is executed as root (exit otherwise)
if [[ `id -u` != 0 ]]; then
  echo "Please execute this script as root!"
  exit 1
fi

GOPATH=$HOME/go
if [ $OS == "Ubuntu" ]; then
  GOROOT=/usr/local/go
elif [ $OS == "Fedora" ]; then
  GOROOT=/usr/lib/golang
fi
PATH=$PATH:$GOPATH/bin:$GOROOT/bin

##################
# Prepare MPTCP namesapce
##################

if [ ${MPTCP} ]
then
  sleep 3
  echo ""
  echo "###############"
  echo "Preparing MPTCP namespace ..."
  MPTCPNS="MPTCPns"
  EXEC_MPTCPNS="ip netns exec ${MPTCPNS}"
  ip netns add ${MPTCPNS}

  # Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
  IP_GW=$SMF_UE_SUBNET"."$((1 + $NUM_UES))
  for i in $(seq 1 $NUM_UES)
  do
    echo ""
    echo "Connecting MPTCP namespace to UE "$i
    VETH_MPTCP="v_mp_"$i
    VETH_MPTCP_H="v_mph_"$i
    ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H
    ifconfig "eth"$i 0.0.0.0 up
    brctl addbr "brmptcp_"$i
    brctl addif "brmptcp_"$i "eth"$i
    brctl addif "brmptcp_"$i $VETH_MPTCP_H
    ip link set $VETH_MPTCP_H up
    ip link set "brmptcp_"$i up
    ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
    $EXEC_MPTCPNS ip link set $VETH_MPTCP up

    IP_MPTCP=$SMF_UE_SUBNET"."$i"/24"
    IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
    ### 3netconfig:	IP_MPTCP="10.1."$i".2/24"
    ### 3netconfig: IP_MPTCP_SIMPLE="10.1."$i".2"
    $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
    $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400 # done to avoid fragmentation which breaks ovpn setup

    #############
    # Configure routing tables within MPTCP namespace --> packets with source IP $IP_MPTCP will get routed through a different interface $VETH_MPTCP
    ### 3netconfig: IP_GW="10.1."$i".1"  # Gateway IP is 10.0.1.1, 10.0.2.1 or 10.0.3.1 depending on the interface
    ### 3netconfig: SMF_UE_SUBNET="10.1."$i
    $EXEC_MPTCPNS ip rule add from $IP_MPTCP_SIMPLE table $i # this rule forces packets coming with this IP address to be routed according to table $i
    $EXEC_MPTCPNS ip rule add oif $VETH_MPTCP table $i # this rule is forces local applications that bind to the interface (like ping -I $VETH_MPTCP) to be routed according to table $i
    $EXEC_MPTCPNS ip route add $SMF_UE_SUBNET".0/24" dev $VETH_MPTCP scope link table $i
    $EXEC_MPTCPNS ip route add default via $IP_GW dev $VETH_MPTCP table $i
    #Adding default gateway through UEns_1
    if [ "$i" == "2" ]; then
      $EXEC_MPTCPNS ip route add default scope global nexthop via $IP_GW dev $VETH_MPTCP
    fi

  done

  # Launching OVPN tunnel over MPTCP
  if [[ $OVPN == True ]]; then
    sleep 5
    echo ""
    echo "Launching OVPN tunnel over MPTCP to transport L2 packets"
    echo ""
    cd $GOPATH/src/free5gc/ovpn-config-client  # openvpn needs to run from this folder
    $EXEC_MPTCPNS openvpn ovpn-client1.conf &

    #TODO: Add check to validate the tap0 interface is available
  fi
fi
