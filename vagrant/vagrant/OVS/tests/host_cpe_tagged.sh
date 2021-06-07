#!/bin/bash
# Using this script, the host will be able to ping the MPTCP proxy but not the CPE
# since frames will be tagged.
# CPE shall be configured with VLAN support.

VLANID=100
  # Create a virtual interface
ip link add link vboxnet0 name vboxnet0.${VLANID} type vlan id ${VLANID}

  # Configure the real interface with the typical IP address, and the virtual interface with an IP address from the VPN's pool
sudo ifconfig vboxnet0 192.168.56.1/24 promisc up
sudo ifconfig vboxnet0.${VLANID} 10.8.0.33/24 promisc up
