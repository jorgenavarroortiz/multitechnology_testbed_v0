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

# Default values
NUM_UES=2
SMF_UE_SUBNET="10.0.1"

usage() { echo "Usage: $0 [-n <NUM_UEs>] [-s <SmfUeSubnet>] [-h]" 1>&2; exit 1; }

while getopts ":n:s:h" o; do
  case "${o}" in
    n)
      n=1
      NUM_UES=${OPTARG}
      echo "NUM_UEs="$NUM_UES
      ;;
    s)
      s=1
      SMF_UE_SUBNET=${OPTARG}
      echo "UE Subnet configured in SMF="$SMF_UE_SUBNET
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

# Assign IP addresses to the network interfaces
ifconfig eth1 ${SMF_UE_SUBNET}.$((1 + $NUM_UES))/24
ifconfig eth2 60.60.0.102/24

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
