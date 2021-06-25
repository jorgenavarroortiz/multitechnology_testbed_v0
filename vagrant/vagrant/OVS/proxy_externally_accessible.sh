#!/bin/bash

tapIF="tap0"

noLines=`sudo ip netns exec MPTCPns ip address show ${tapIF} | grep ${tapIF} -c`

if [[ $noLines > 0 ]]; then
  echo "${tapIF} found!"
else
  echo "${tapIF} not found. Have you started the OVPN server? Exiting..."
  exit 1
fi

IPADDRESS1=`sudo ip netns exec MPTCPns ip address show ${tapIF} | grep inet | grep "scope global" | cut -d" " -f 6`
IPADDRESS2=`sudo ip address show m${tapIF} | grep inet | grep "scope global" | cut -d" " -f 6`
IPADDRESS=''

if [[ $IPADDRESS1 == "" ]]; then
  echo "${tapIF} already has no IP address, checking m${tapIF} interface..."
  if [[ $IPADDRESS2 == "" ]]; then
    echo "m${tapIF} also has no IP address, exiting..."
    exit 1
  else
    IPADDRESS=$IPADDRESS2
    echo "IP address for m${tapIF}: ${IPADDRESS}"
  fi
else
  IPADDRESS=$IPADDRESS1
  echo "IP address for m${tapIF}: ${IPADDRESS}"
fi


# Create a pair mtap$i <-> vtap$i
# vtap$i (virtual tap$i) will be in the MPTCPns namespace
# mtap$i (main tap$i) will be in the main namespace
# --> mtap$i can be used to access the VPN from the main namespace
sudo ip link add v${tapIF} type veth peer name m${tapIF}
sudo ip link set m${tapIF} up
sudo ip link set v${tapIF} netns MPTCPns
sudo ip netns exec MPTCPns ip link set v${tapIF} up
sudo ip netns exec MPTCPns brctl addbr br_${tapIF}
sudo ip netns exec MPTCPns brctl addif br_${tapIF} v${tapIF}
sudo ip netns exec MPTCPns brctl addif br_${tapIF} ${tapIF}

sudo ip netns exec MPTCPns ifconfig br_${tapIF} 0 promisc up
sudo ip netns exec MPTCPns ifconfig ${tapIF} 0 promisc up
sudo ip netns exec MPTCPns ifconfig v${tapIF} 0 promisc up
sudo ifconfig m${tapIF} ${IPADDRESS} promisc up

# Act as a router
sudo sysctl -w net.ipv4.ip_forward=1
