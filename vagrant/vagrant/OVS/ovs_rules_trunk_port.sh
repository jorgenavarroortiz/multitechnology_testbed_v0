#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Include these VLANs in the trunk interface of OVS"
  echo "Usage: $0 -i <interface> -v <VLAN ID 1> -v <VLAN ID 2> -v <VLAN ID 3> ..." 1>&2;
  echo ""
  echo "E.g. for CPE: $0 -i eth4 -v 100 -v 200 -v 300"
  exit 1;
}

v=0
while getopts ":i:v:" o; do
  case "${o}" in
    i)
      i=1
      INTERFACE=${OPTARG}
      echo "INTERFACE=$INTERFACE"
      ;;
    v)
      v=v+1
      VLANIDarray+=("$OPTARG")
      echo "VLANID=${OPTARG}"
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
# Adding VLANs to trunk port
############################

#declare -a VLANIDarray=(100 200 300)
#echo "VLANIDarray: $VLANIDarray"
noVLANs=${#VLANIDarray[@]}
noVLANs=$(($noVLANs-1)) # Starting from 0, so it is the size of the array minus one

# Configure VLANs
  # Trunk port
VLANIDstring=$(IFS=, ; echo "${VLANIDarray[*]}")
sudo ovs-vsctl set port ${INTERFACE} trunks=${VLANIDstring}
