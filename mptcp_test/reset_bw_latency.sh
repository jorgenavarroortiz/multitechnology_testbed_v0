#!/bin/bash
# Jorge Navarro, UGR (2020)

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -i <interface>" 1>&2;
  echo " E.g.: $0 -i eth2";
  echo "       <interface> ......... network interface, e.g. eth0, wlan0, ..."
  exit 1;
}

while getopts ":i:" o; do
    case "${o}" in
        i)
            i=1
            INTERFACE=${OPTARG}
            echo "INTERFACE="$INTERFACE
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

# Clean previous rules
echo "Cleaning rules (latency and bandwidth) for ${INTERFACE}"
sudo tc qdisc del dev $INTERFACE root 2> /dev/null

# Show rules
#sudo tc qdisc show dev $INTERFACE
