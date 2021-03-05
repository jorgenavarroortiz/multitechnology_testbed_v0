#!/usr/bin/env bash
#
# This script is used to setup the MPTCP proxy
#
# Author: Daniel Camps (daniel.camps@i2cat.net)
# Copyright: i2CAT
# Modified by Jorge Navarro-Ortiz (jorgenavarro@ugr.es)

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 [-i <IP address/mask>] [-I <interface name>] [-g <gateway IP address>] [-P <path manager>] [-S <scheduler>] [-C <congestion control>] [-h]" 1>&2;
  echo ""
  echo "Example: $0 -i 60.60.0.101/24 -I eth1 -g 60.60.0.102 -P fullmesh -S default -C olia"
  echo ""
  echo "       <path manager> ........... default, fullmesh, ndiffports, binder"
  echo "       <scheduler> .............. default, roundrobin, redundant"
  echo "       <congestion control> ..... reno, cubic, lia, olia, wvegas, balia, mctcpdesync"
  echo ""
  echo "       -h ....................... this help"
  exit 1;
}

# Default values
MYIP="60.60.0.101"
GATEWAY="60.60.0.102"
PATHMANAGER="fullmesh"
SCHEDULER="default"
CONGESTIONCONTROL="olia"

while getopts ":i:I:g:P:S:C:h" o; do
  case "${o}" in
    i)
      MYIP=${OPTARG}
      i=1
      echo "MYIP="$MYIP
      ;;
    I)
      MYIFNAME=${OPTARG}
      I=1
      echo "MYIFNAME="$MYIFNAME
      ;;
    g)
      GATEWAY=${OPTARG}
	    g=1
	    echo "GATEWAY="$GATEWAY
      ;;
    P)
      P=1
      PATHMANAGER=${OPTARG}
      echo "PATHMANAGER="$PATHMANAGER
      ;;
    S)
      S=1
      SCHEDULER=${OPTARG}
      echo "SCHEDULER="$SCHEDULER
      ;;
    C)
      C=1
      CONGESTIONCONTROL=${OPTARG}
      echo "CONGESTIONCONTROL="${OPTARG}
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

# Check if it is executed as root (exit otherwise)
if [[ `id -u` != 0 ]]; then
  echo "Please execute this script as root!"
  exit 1
fi

# Modify tunable variables
sysctl -w net.mptcp.mptcp_enabled=1     # Default 1
sysctl -w net.mptcp.mptcp_checksum=1    # Default 1 (both sides have to be 0 in order to disable this)
sysctl -w net.mptcp.mptcp_syn_retries=3 # Specifies how often we retransmit a SYN with the MP_CAPABLE-option. Default 3
sysctl -w net.mptcp.mptcp_path_manager=$PATHMANAGER
sysctl -w net.mptcp.mptcp_scheduler=$SCHEDULER

# Congestion control
sysctl -w net.ipv4.tcp_congestion_control=$CONGESTIONCONTROL

# Add data network IP address to eth1
ifconfig $MYIFNAME $MYIP up

# Add static route to reach MPTCP UEs
while read p; do
  ip route add $p via $GATEWAY dev eth1
done <if_routes.txt

# Launch openvpn server
echo ""
echo "######################"
echo "# Launching OVPN server"
echo ""
cd ovpn-config-proxy/
openvpn ovpn-server.conf &

# TODO: Bridge tap0 with exit interface
