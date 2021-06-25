#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Include this VLAN in one access interface of OVS"
  echo "Usage: $0 -i <interface> -v <VLAN ID>" 1>&2;
  echo ""
  echo "E.g. for CPE, path 1: $0 -i mtap0 -v 100"
  echo "E.g. for CPE, path 2: $0 -i mtap1 -v 200"
  echo "E.g. for CPE, path 3: $0 -i mtap2 -v 300"
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


############################
# Adding VLAN to access port
############################

# Configure VLANs
  # Access port
sudo ovs-vsctl set port ${INTERFACE} tag=${VLANID}
