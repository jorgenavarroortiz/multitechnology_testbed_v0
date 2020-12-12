#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -i <interface> -b <bandwidth> -l <latency>" 1>&2;
  echo " E.g.: $0 -i eth2 -b 100Mbit -l 100ms";
  echo "       <interface> ......... network interface, e.g. eth0, wlan0, ..."
  echo "       <bandwidth> ......... e.g. 100Mbit"
  echo "       <latency> ........... e.g. 100ms"
  exit 1;
}

while getopts ":i:b:l:" o; do
    case "${o}" in
        i)
            i=1
            INTERFACE=${OPTARG}
            echo "INTERFACE="$INTERFACE
            ;;
        b)
            b=1
            BANDWIDTH=${OPTARG}
            echo "BANDWIDTH="$BANDWIDTH
            ;;
        l)
            l=1
            LATENCY=${OPTARG}
            echo "LATENCY="$LATENCY
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${b}" ] || [ -z "${l}" ]; then
    usage
fi

#############################
# Setting bandwidth and latency
#############################
# Clean previous rules
sudo tc qdisc del dev $INTERFACE root 2> /dev/null
# Set bandwidth and latency
echo "Setting ${INTERFACE} latency to ${LATENCY} and bandwidth to ${BANDWIDTH}"
sudo tc qdisc add dev $INTERFACE root handle 1: tbf rate ${BANDWIDTH} burst 1600 limit 1600 2> /dev/null
sudo tc qdisc add dev $INTERFACE parent 1: handle 2: netem delay ${LATENCY} 2> /dev/null
