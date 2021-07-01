#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Show OF rules for this OVS switch"
  echo "Usage: $0 -b <bridge>" 1>&2;
  echo ""
  echo "E.g. for CPE: $0 -b vpn-br"
  exit 1;
}

while getopts ":b:" o; do
  case "${o}" in
    b)
      b=1
      BRIDGE=${OPTARG}
#      echo "BRIDGE=$BRIDGE"
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${b}" ]; then
  usage
fi


###############
# Show OF rules
###############

sudo ovs-ofctl show ${BRIDGE}
