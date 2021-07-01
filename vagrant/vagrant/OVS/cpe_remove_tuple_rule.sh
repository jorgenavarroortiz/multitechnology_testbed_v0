#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Remove a flow rule, usually utilized to configure the client (source) to connect to a server (destination) through a specific proxy"
  echo "Usage: $0 -s <source IP address> [-d <destination IP address>] [-p <protocol>] [-S <source port>] [-D <destination port>]" 1>&2;
  echo ""
  echo "E.g. $0 -s 66.6.6.22"
  exit 1;
}

while getopts ":s:d:S:D:p:" o; do
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
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${s}" ]; then
  usage
fi


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

