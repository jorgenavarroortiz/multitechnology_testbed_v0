#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -i <interface> -s <state>" 1>&2;
  echo " E.g.: $0 -i eth2 -s backup";
  echo "       <interface> ......... network interface, e.g. eth0, wlan0, ..."
  echo "       <state> ............. on, off, backup"
  exit 1;
}

# Default values
INTERFACE=eth2
STATE=on

while getopts ":i:s:" o; do
    case "${o}" in
        i)
            i=1
            INTERFACE=${OPTARG}
            echo "INTERFACE="$INTERFACE
            ;;
        s)
            s=1
            STATE=${OPTARG}
            echo "STATE="$STATE
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${s}" ]; then
    usage
fi

#############################
# Changing interface MPTCP state
#############################
sudo ip link set dev $INTERFACE multipath $STATE
