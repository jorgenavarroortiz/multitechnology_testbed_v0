#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Remove this VLAN from trunk access interface of OVS"
  echo "Usage: $0 -i <interface> -v <VLAN ID>" 1>&2;
  echo ""
  echo "E.g. for CPE, eth4, remove VLAN 100: $0 -i eth4 -v 100"
  exit 1;
}

while getopts ":i:v:" o; do
  case "${o}" in
    i)
      i=1
      INTERFACE=${OPTARG}
      echo "INTERFACE=$INTERFACE"
      ;;
    v)
      v=1
      VLANID=${OPTARG}
      echo "VLANID=$VLANID"
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${v}" ]; then
  usage
fi


###############################
# Removing VLAN from trunk port
###############################

# Configure VLANs
  # Trunk port
sudo ovs-vsctl remove port ${INTERFACE} trunk ${VLANID}
