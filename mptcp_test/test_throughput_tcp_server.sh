#!/bin/bash
FILENAME=$1

if [ $# -eq 1 ]; then
   echo "Saving results in file ${FILENAME}"
   iperf -s | tee $FILENAME
else
   echo "Not saving results"
   iperf -s
fi
