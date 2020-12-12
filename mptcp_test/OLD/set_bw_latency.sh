#!/bin/bash
#LATENCY1=100ms
#BANDWIDTH1=100Mbit
#LATENCY2=100ms
#BANDWIDTH2=100Mbit

if [ $# -eq 4 ]; then
   LATENCY1=$1
   BANDWIDTH1=$2
   LATENCY2=$3
   BANDWIDTH2=$4
else
   echo ""
   echo "Syntax: $0 <latency_eth1> <bandwidth_eth1> <latency_eth2> <bandwidth_eth2>"
   echo "  E.g.: $0 100ms 100Mbit 100ms 100Mbit"
   echo ""
   exit 0
fi

# Clean previous rules
sudo tc qdisc del dev eth1 root 2> /dev/null
sudo tc qdisc del dev eth2 root 2> /dev/null

# Set bandwidth and latency
echo "Setting eth1 latency to ${LATENCY1} and bandwidth to ${BANDWIDTH1}"
sudo tc qdisc add dev eth1 root handle 1: tbf rate ${BANDWIDTH1} burst 1600 limit 1600 2> /dev/null
sudo tc qdisc add dev eth1 parent 1: handle 2: netem delay ${LATENCY1} 2> /dev/null
echo "Setting eth2 latency to ${LATENCY2} and bandwidth to ${BANDWIDTH2}"
sudo tc qdisc add dev eth2 root handle 1: tbf rate ${BANDWIDTH2} burst 1600 limit 1600 2> /dev/null
sudo tc qdisc add dev eth2 parent 1: handle 2: netem delay ${LATENCY2} 2> /dev/null

# Show rules
#sudo tc qdisc show dev eth1
#sudo tc qdisc show dev eth2

