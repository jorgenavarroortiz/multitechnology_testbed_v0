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
  echo "Usage: $0 [-i <IP address>] [-g <gateway IP address>] [-p <path manager>] [-s <scheduler>] [-c <congestion control>] [-h]" 1>&2;
  echo ""
  echo "Example: $0 -i 60.60.0.101 -g 60.60.0.102 -p fullmesh -s default -c olia"
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

while getopts ":i:g:p:s:c:h" o; do
  case "${o}" in
    i)
      MYIP=${OPTARG}
      i=1
      echo "MYIP="$MYIP
	    ;;
    g)
      GATEWAY=${OPTARG}
	    g=1
	    echo "GATEWAY="$GATEWAY
      ;;
    p)
      p=1
      PATHMANAGER=${OPTARG}
      echo "PATHMANAGER="$PATHMANAGER
      ;;
    s)
      s=1
      SCHEDULER=${OPTARG}
      echo "SCHEDULER="$SCHEDULER
      ;;
    c)
      c=1
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

if [ $h -eq 1 ]; then
  usage
fi

# Modify tunable variables
sudo sysctl -w net.mptcp.mptcp_enabled=1     # Default 1
sudo sysctl -w net.mptcp.mptcp_checksum=1    # Default 1 (both sides have to be 0 in order to disable this)
sudo sysctl -w net.mptcp.mptcp_syn_retries=3 # Specifies how often we retransmit a SYN with the MP_CAPABLE-option. Default 3
sudo sysctl -w net.mptcp.mptcp_path_manager=$PATHMANAGER
sudo sysctl -w net.mptcp.mptcp_scheduler=$SCHEDULER

# Congestion control
sudo sysctl -w net.ipv4.tcp_congestion_control=$CONGESTIONCONTROL

# Add data network IP address to eth1
sudo ifconfig eth1 $MYIP"/24" up

# Add static route to reach MPTCP UEs
while read p; do
  sudo ip route add $p via $GATEWAY dev eth1
done <if_routes.txt

# Launch openvpn server
echo ""
echo "######################"
echo "# Launching OVPN server"
echo ""
cd ovpn-config-proxy/
openvpn ovpn-server.conf &

# TODO: Bridge tap0 with exit interface
