#!/bin/bash
#
# Jorge Navarro-Ortiz, University of Granada, jorgenavarro@ugr.es
#
# This script assumes the interfaces explained in set_MPTCP_parameters.sh

MACHINE=`hostname`
echo "Configuring ${MACHINE}..."

if [[ $MACHINE == "mptcpUe" ]]; then
  echo "Disabling interface towards Internet..."
  sudo ifconfig eth0 down
  echo "Changing IP addresses..."
  sudo ifconfig eth1 10.1.1.1/24
  sudo ifconfig eth2 10.1.1.2/24
  echo "Changing routes..."
  sudo route add default gw 10.1.1.222 dev eth1
elif [[ $MACHINE == "mptcpUe1" ]]; then
  echo "Disabling interface towards Internet..."
  sudo ifconfig eth0 down
  echo "Changing IP addresses..."
  sudo ifconfig eth1 10.1.1.1/24
  sudo ifconfig eth2 10.1.1.2/24
  echo "Changing routes..."
  sudo route add default gw 10.1.1.3 dev eth1
elif [[ $MACHINE == "mptcpUe2" ]]; then
  echo "Disabling interface towards Internet..."
  sudo ifconfig eth0 down
  echo "Changing IP addresses..."
  sudo ifconfig eth1 10.1.1.3/24
  sudo ifconfig eth2 10.1.1.4/24
  echo "Changing routes..."
  sudo route add default gw 10.1.1.1 dev eth1
elif [[ $MACHINE == "free5gc" ]]; then
  echo "Disabling interface towards Internet..."
  sudo ifconfig eth0 down
  echo "Changing IP addresses and forwarding..."
  sudo ifconfig eth1 10.1.1.222/24
  sudo ifconfig eth2 60.60.0.102/24
  sudo sysctl -w net.ipv4.ip_forward=1
elif [[ $MACHINE == "mptcpProxy" ]]; then
  echo "Disabling interface towards Internet..."
  sudo ifconfig eth0 down
  echo "Changing IP addresses..."
  sudo ifconfig eth1 60.60.0.101/24
  echo "Changing routes..."
  sudo route add default gw 60.60.0.102
fi
