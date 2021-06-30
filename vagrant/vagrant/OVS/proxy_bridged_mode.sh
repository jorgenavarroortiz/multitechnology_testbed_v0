#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

# Remove previous bridge
sudo ifconfig toserver-br down 2> /dev/null
sudo brctl delbr toserver-br 2> /dev/null

# Create new bridge
#sudo ifconfig mtap0 0 promisc up
sudo ifconfig eth2 0 promisc up
sudo brctl addbr toserver-br
sudo brctl addif toserver-br mtap0
sudo brctl addif toserver-br eth2
sudo ifconfig toserver-br promisc up

# Add STP to current bridges on proxy
sudo brctl stp toserver-br on
sudo brctl stp brmptcp_1 on
sudo ip netns exec MPTCPns brctl stp br_tap0 on
