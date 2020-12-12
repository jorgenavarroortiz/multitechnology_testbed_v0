#!/bin/bash
if [ $# -eq 1 ]; then
   PEER=$1
   echo "Testing latency against ${PEER} but not saving results"
   sudo mtr -T -P 22 --no-dns -i 0.1 -c 100 $PEER -C | tee
elif [ $# -eq 2 ]; then
   PEER=$1
   FILENAME=$2
   echo "Testing latency against ${PEER} and saving results in file ${FILENAME}"
   sudo mtr -T -P 22 --no-dns -i 0.1 -c 100 $PEER -C | tee $FILENAME
else
   echo ""
   echo "Syntax: $0 <IP address> [<filename>]"
   echo "  E.g.: $0 192.168.13.2 latency.log"
   echo ""
fi
