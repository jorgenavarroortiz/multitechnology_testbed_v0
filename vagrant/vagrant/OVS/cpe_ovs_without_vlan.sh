#!/bin/bash
# Check if MPTCPns namespace exists. If not, show a warning and exit.
# *** TO BE DONE ***
noLines=`sudo ip netns list | grep -c MPTCPns`
if [[ $noLines > 0 ]]; then
  echo "MPTCPns detected!"
else
  echo "MPTCPns is not detected. Please first connect to the MPTCP proxy, and then relaunch this script."
  exit 1
fi

# Delete previous configuration
sudo ovs-vsctl del-br vpn-br

# OVS switch
sudo ovs-vsctl add-br vpn-br
sudo ovs-vsctl add-port vpn-br eth4

# Configure interfaces
sudo ifconfig eth4 0 promisc up
sudo ifconfig vpn-br 10.8.0.2/24 promisc up

# Add tap0 within the MPTCPns namespace to the OVS switch
  # Create a pair mtap0 <-> vtap0
  # vtap0 (virtual tap0) will be in the MPTCPns namespace
  # mtap0 (main tap0) will be in the main namespace
  # --> mtap0 can be used to access the VPN from the main namespace, and
  #     it can be connected to the OVS switch
sudo ip link add vtap0 type veth peer name mtap0
sudo ip link set mtap0 up
sudo ip link set vtap0 netns MPTCPns
sudo ip netns exec MPTCPns ip link set vtap0 up
  # vtap0 will be bridged to tap0 using standard bridge control (brctl)
sudo ip netns exec MPTCPns brctl addbr br_tap0
sudo ip netns exec MPTCPns brctl addif br_tap0 vtap0
sudo ip netns exec MPTCPns brctl addif br_tap0 tap0
sudo ip netns exec MPTCPns ifconfig br_tap0 0 promisc up
sudo ip netns exec MPTCPns ifconfig tap0 0 promisc up
sudo ip netns exec MPTCPns ifconfig vtap0 0 promisc up
  # mtap0 will be in the OVS
sudo ovs-vsctl add-port vpn-br mtap0
sudo ifconfig mtap0 0 promisc up

# Configure routes (possible routes accessible through the VPN)
# Currently all entities are in the same LAN as the VPN (10.8.0.0/24),
# so no additional routes are required.
#sudo route add default gw 192.168.56.1

# Flow entries (if required, by default using NORMAL i.e. a standard learning switch)
#sudo ovs-ofctl add-flow vpn-br in_port=eth4,actions=LOCAL -OOpenFlow13
#sudo ovs-ofctl add-flow vpn-br in_port=LOCAL,actions=output:eth4 -OOpenFlow13
