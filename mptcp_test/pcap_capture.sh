#!/bin/bash
DIRECTORY=$1

if [ $# -eq 1 ]; then
   echo "Saving results in directory ${DIRECTORY}"
   mkdir ${DIRECTORY}
   touch ${DIRECTORY}/capture.pcap
   chmod o=rw ${DIRECTORY}/capture.pcap
   sudo tshark -i eth1 -i eth2 -w ${DIRECTORY}/capture.pcap
else
   echo "Syntax: $0 <directory>"
fi
