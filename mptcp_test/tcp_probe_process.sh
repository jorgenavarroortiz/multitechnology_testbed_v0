#!/bin/bash
FILENAME=$1
FILENAMEWOEXT=`echo "$FILENAME" | cut -d'.' -f1`
MPTCPFLOW1=$2
MPTCPFLOW2=$3

if [ $# -eq 3 ]; then
   # CHANGE THIS TO SELECT THE PROPER MPTCP SUBFLOW
   MPTCPFLOW=$MPTCPFLOW1
   grep tcp_probe $FILENAME | grep mptcp=$MPTCPFLOW | awk '{ printf substr($4, 0, length($4)-1)" "substr($12, length("snd_cwnd=")+1)" "substr($13, length("ssthresh=")+1)" "substr($14, length("snd_wnd=")+1)" "substr($15, length("srtt=")+1)" "substr($16, length("rcv_wnd=")+1)" "; print ""}' > ${FILENAMEWOEXT}_processed_${MPTCPFLOW}.txt
   # AND REPEAT WITH ALL REQUIRED MPTCP SUBFLOWS...
   MPTCPFLOW=$MPTCPFLOW2
   grep tcp_probe $FILENAME | grep mptcp=$MPTCPFLOW | awk '{ printf substr($4, 0, length($4)-1)" "substr($12, length("snd_cwnd=")+1)" "substr($13, length("ssthresh=")+1)" "substr($14, length("snd_wnd=")+1)" "substr($15, length("srtt=")+1)" "substr($16, length("rcv_wnd=")+1)" "; print ""}' > ${FILENAMEWOEXT}_processed_${MPTCPFLOW}.txt
else
   echo "Syntax: $0 <filename> <flow index 1> <flow index 2>"
   exit 0
fi
