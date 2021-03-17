#!/usr/bin/env bash
#
# This script is used to setup a 5GClarity UE with 2 namespaces representing the WiFi and LiFi interfaces and one MPTCP namesapce to aggregate traffic over the 2 access networks
#
# Author: Daniel Camps (daniel.camps@i2cat.net)
# Copyright: i2CAT

SMFCard="eth1" # "enp2s0"
DNCard="eth2" # "enx6038e0e3083f"

#############################
# Parsing inputs parameters
#############################

usage() { echo "Usage: $0 [-n <NUM_UEs>] [-s <SmfUeSubnet>]" 1>&2; exit 1; }

while getopts ":n:mas:o:" o; do
    case "${o}" in
        n)
            NUM_UES=${OPTARG}
	    n=1
	    echo "NUM_UEs="$NUM_UES
            ;;
        s)
            t=1
            SMF_UE_SUBNET=${OPTARG}
            echo "UE Subnet configured in SMF="$SMF_UE_SUBNET
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${t}" ] || [ -z "${n}" ]; then
    usage
fi

# Assign IP addresses to the network interfaces
sudo ifconfig $SMFCard ${SMF_UE_SUBNET}.$((1 + $NUM_UES))/24
sudo ifconfig $DNCard 60.60.0.102/24

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
