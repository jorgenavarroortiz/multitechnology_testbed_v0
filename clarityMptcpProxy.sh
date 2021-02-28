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
  echo "Usage: $0 [-i <IP address>] [-g <gateway IP address>]" 1>&2;
  echo "Example: $0 -i 60.60.0.101 -g 60.60.0.102"
  exit 1;
}

while getopts ":i:g:" o; do
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
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${g}" ]; then
    usage
fi

####################
# Configure MPTCP path manager
####################
sudo sysctl -w net.mptcp.mptcp_path_manager=fullmesh

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
