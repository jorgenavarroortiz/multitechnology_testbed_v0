#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Configure the client (source) to connect to a server (destination) through a specific proxy"
  echo "Usage: $0 -s <source IP address> [-d <destination IP address>] [-p <protocol>] [-S <source port>] [-D <destination port>] -P <proxy>" 1>&2;
  echo ""
  echo "E.g. $0 -s 66.6.6.22 -P 1"
  exit 1;
}

while getopts ":s:d:P:S:D:p:" o; do
  case "${o}" in
    s)
      s=1
      SRCIPADDRESS=${OPTARG}
#      echo "SRCIPADDRESS=$SRCIPADDRESS"
      ;;
    S)
      S=1
      SRCPORT=${OPTARG}
#      echo "SRCPORT=$SRCPORT"
      ;;
    d)
      d=1
      DSTIPADDRESS=${OPTARG}
#      echo "DSTIPADDRESS=$DSTIPADDRESS"
      ;;
    D)
      D=1
      DSTPORT=${OPTARG}
#      echo "DSTPORT=$DSTPORT"
      ;;
    p)
      p=1
      PROTOCOL=${OPTARG}
#      echo "PROTOCOL=$PROTOCOL"
      ;;
    P)
      P=1
      PROXY=${OPTARG}
#      echo "PROXY=$PROXY"
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${P}" ]; then
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


# Remove previous flows related to this client
sudo ovs-ofctl del-flows vpn-br
#sudo ovs-ofctl add-flow vpn-br priority=0,actions=output:NORMAL

  # For ARP
if [[ $d -eq 1 ]]; then
  sudo ovs-ofctl del-flows vpn-br arp,nw_dst=${SRCIPADDRESS},nw_src=${DSTIPADDRESS}
  sudo ovs-ofctl del-flows vpn-br arp,nw_src=${SRCIPADDRESS},nw_dst=${DSTIPADDRESS}
else
  sudo ovs-ofctl del-flows vpn-br arp,nw_dst=${SRCIPADDRESS}
  sudo ovs-ofctl del-flows vpn-br arp,nw_src=${SRCIPADDRESS}
fi

  # To client (through eth4 -> check using "ovs-ofctl show vpn-br")
RULE="nw_dst=${SRCIPADDRESS}"
if [[ $d -eq 1 ]]; then RULE="${RULE},nw_src=${DSTIPADDRESS}"; fi
if [[ $p -eq 1 ]]; then RULE="${RULE},protocol=${PROTOCOL}"; fi
if [[ $S -eq 1 ]]; then RULE="${RULE},tp_src=${SRCPORT}"; fi
if [[ $D -eq 1 ]]; then RULE="${RULE},tp_dst=${DSTPORT}"; fi
sudo ovs-ofctl del-flows vpn-br ip,${RULE}

  # Through proxy
RULE="nw_src=${SRCIPADDRESS}"
if [[ $d -eq 1 ]]; then RULE="${RULE},nw_dst=${DSTIPADDRESS}"; fi
if [[ $p -eq 1 ]]; then RULE="${RULE},protocol=${PROTOCOL}"; fi
if [[ $S -eq 1 ]]; then RULE="${RULE},tp_dst=${SRCPORT}"; fi
if [[ $D -eq 1 ]]; then RULE="${RULE},tp_src=${DSTPORT}"; fi
sudo ovs-ofctl del-flows vpn-br ip,${RULE}

# Add new flows for this client
  # For ARP
if [[ $d -eq 1 ]]; then
  sudo ovs-ofctl add-flow vpn-br priority=10,arp,nw_dst=${SRCIPADDRESS},nw_src=${DSTIPADDRESS},actions=output:1
  sudo ovs-ofctl add-flow vpn-br priority=10,arp,nw_src=${SRCIPADDRESS},nw_dst=${DSTIPADDRESS},actions=output:$OUTPUTPORT
else
  sudo ovs-ofctl add-flow vpn-br priority=10,arp,nw_dst=${SRCIPADDRESS},actions=output:1
  sudo ovs-ofctl add-flow vpn-br priority=10,arp,nw_src=${SRCIPADDRESS},actions=output:$OUTPUTPORT
fi

  # To client (through eth4 -> check using "ovs-ofctl show vpn-br")
RULE="nw_dst=${SRCIPADDRESS}"
if [[ $d -eq 1 ]]; then RULE="${RULE},nw_src=${DSTIPADDRESS}"; fi
if [[ $p -eq 1 ]]; then RULE="${RULE},protocol=${PROTOCOL}"; fi
if [[ $S -eq 1 ]]; then RULE="${RULE},tp_src=${SRCPORT}"; fi
if [[ $D -eq 1 ]]; then RULE="${RULE},tp_dst=${DSTPORT}"; fi
sudo ovs-ofctl add-flow vpn-br priority=10,ip,${RULE},actions=output:1

  # Through proxy
RULE="nw_src=${SRCIPADDRESS}"
if [[ $d -eq 1 ]]; then RULE="${RULE},nw_dst=${DSTIPADDRESS}"; fi
if [[ $p -eq 1 ]]; then RULE="${RULE},protocol=${PROTOCOL}"; fi
if [[ $S -eq 1 ]]; then RULE="${RULE},tp_dst=${SRCPORT}"; fi
if [[ $D -eq 1 ]]; then RULE="${RULE},tp_src=${DSTPORT}"; fi
sudo ovs-ofctl add-flow vpn-br priority=10,ip,${RULE},actions=output:$OUTPUTPORT
