#!/bin/bash
DIRECTORY=$1

if [ $# -eq 1 ]; then
   echo "Processing results in directory ${DIRECTORY}"
   cd ${DIRECTORY}
   sudo mptcptrace -f capture.pcap -s -G 50 -F 3 -a -r 1
else
   echo "Syntax: $0 <directory>"
fi
