#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Configure the client to use a specific proxy"
  echo "Usage: $0 -s <client IP address> -p <proxy>" 1>&2;
  echo ""
  echo "E.g. $0 -s 66.6.6.22 -p 1"
  exit 1;
}

while getopts ":s:p:" o; do
  case "${o}" in
    s)
      s=1
      IPADDRESS=${OPTARG}
#      echo "IPADDRESS=$IPADDRESS"
      ;;
    p)
      p=1
      PROXY=${OPTARG}
#      echo "PROXY=$PROXY"
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${p}" ]; then
  usage
fi


#######################################################
# Configuring CPE so client connects through this proxy
#######################################################

if [ $PROXY -eq 1 ]; then
#  echo "Proxy 1 selected!"
  OUTPUTPORT=2 # mtap0, check using "ovs-ofctl show vpn-br"
elif [ $PROXY -eq 2 ]; then
#  echo "Proxy 2 selected!"
  OUTPUTPORT=3 # mtap0, check using "ovs-ofctl show vpn-br"
elif [ $PROXY -eq 3 ]; then
#  echo "Proxy 3 selected!"
  OUTPUTPORT=4 # mtap0, check using "ovs-ofctl show vpn-br"
fi


# Remove previous flows
sudo ovs-ofctl del-flows vpn-br
sudo ovs-ofctl add-flow vpn-br priority=0,actions=output:NORMAL

# To client (through eth4 -> check using "ovs-ofctl show vpn-br")
sudo ovs-ofctl add-flow vpn-br priority=10,ip,nw_dst=${IPADDRESS},actions=output:1
sudo ovs-ofctl add-flow vpn-br priority=10,arp,nw_dst=${IPADDRESS},actions=output:1
# Through proxy (remove access through other proxies)
sudo ovs-ofctl add-flow vpn-br priority=10,ip,nw_src=${IPADDRESS},actions=output:$OUTPUTPORT
sudo ovs-ofctl add-flow vpn-br priority=10,arp,nw_src=${IPADDRESS},actions=output:$OUTPUTPORT
