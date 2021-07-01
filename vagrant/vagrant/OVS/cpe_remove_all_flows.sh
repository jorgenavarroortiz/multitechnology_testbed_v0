#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2021

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Remove all OF rules"
  echo ""
  echo "E.g. $0"
  exit 1;
}

while getopts ":h" o; do
  case "${o}" in
    h)
      usage()
      exit 0
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

# Remove all flows
sudo ovs-ofctl del-flows vpn-br

