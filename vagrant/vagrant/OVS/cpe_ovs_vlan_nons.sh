#!/bin/bash

IFTOCLIENT=`cat if_toclient.txt`

#declare -a VLANIDarray=(100 200 300)
declare -a VLANIDarray=(100 200)
noVLANs=${#VLANIDarray[@]}
noVLANs=$(($noVLANs-1)) # Starting from 0, so it is the size of the array minus one

# Check if MPTCPns namespace exists. If not, show a warning and exit.
#noLines=`sudo ip netns list | grep -c MPTCPns`
#if [[ $noLines > 0 ]]; then
#  echo "MPTCPns detected!"
#else
#  echo "MPTCPns is not detected. Please first connect to the MPTCP proxy, and then relaunch this script."
#  exit 1
#fi

# Delete previous configuration
sudo ovs-vsctl del-br vpn-br >/dev/null 2>&1

# OVS switch
sudo ovs-vsctl add-br vpn-br
sudo ovs-vsctl add-port vpn-br ${IFTOCLIENT}

# Configure interfaces
sudo ifconfig ${IFTOCLIENT} 0 promisc up
sudo ifconfig vpn-br 0 promisc up
#for (( i=0; i<=${noVLANs}; i++ ))
#do
#  sudo ifconfig vpn-br 10.8.0.2/24 promisc up
#done

for (( i=0; i<=${noVLANs}; i++ ))
do
  VLANID=${VLANIDarray[$i]}
  # Add tap$i within the MPTCPns namespace to the OVS switch
    # Create a pair mtap$i <-> vtap$i
    # vtap$i (virtual tap$i) will be in the MPTCPns namespace
    # mtap$i (main tap$i) will be in the main namespace
    # --> mtap$i can be used to access the VPN from the main namespace, and
    #     it can be connected to the OVS switch
#  sudo ip link add vtap$i type veth peer name mtap$i
#  sudo ip link set mtap$i up
#  sudo ip link set vtap$i netns MPTCPns
#  sudo ip netns exec MPTCPns ip link set vtap$i up
    # vtap$i will be bridged to tap$i using standard bridge control (brctl)
#  sudo ip netns exec MPTCPns brctl addbr br_tap$i
#  sudo ip netns exec MPTCPns brctl addif br_tap$i vtap$i
#  sudo ip netns exec MPTCPns brctl addif br_tap$i tap$i
#  sudo ip netns exec MPTCPns ifconfig br_tap$i 0 promisc up
#  sudo ip netns exec MPTCPns ifconfig tap$i 0 promisc up
  sudo ifconfig tap$i 0 promisc up
#  sudo ip netns exec MPTCPns ifconfig vtap$i 0 promisc up
    # mtap$i will be in the OVS
#  sudo ovs-vsctl add-port vpn-br mtap$i
  sudo ovs-vsctl add-port vpn-br tap$i
#  sudo ifconfig mtap$i 0 promisc up
done

### *** LET THE RULES BE IN A DIFFERENT SCRIPT ***
## Configure VLANs
#  # Trunk port
#VLANIDstring=$(IFS=, ; echo "${VLANIDarray[*]}")
#sudo ovs-vsctl set port ${IFTOCLIENT} trunks=${VLANIDstring}
#for (( i=0; i<=${noVLANs}; i++ ))
#do
#  # Access port
#  sudo ovs-vsctl set port mtap$i tag=${VLANIDarray[$i]}
#done

# Configure routes (possible routes accessible through the VPN)
# Currently all entities are in the same LAN as the VPN (10.8.0.0/24),
# so no additional routes are required.
#sudo route add default gw 192.168.56.1

# Flow entries (if required, by default using NORMAL i.e. a standard learning switch)
#sudo ovs-ofctl add-flow vpn-br in_port=${IFTOCLIENT},actions=LOCAL -OOpenFlow13
#sudo ovs-ofctl add-flow vpn-br in_port=LOCAL,actions=output:${IFTOCLIENT} -OOpenFlow13

sudo ovs-vsctl set bridge vpn-br stp_enable=true
