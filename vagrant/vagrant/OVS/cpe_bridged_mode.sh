#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

sudo brctl stp brmptcp_1 on
sudo brctl stp brmptcp_2 on
sudo brctl stp brmptcp_3 on
sudo ip netns exec MPTCPns brctl stp br_tap0 on
sudo ip netns exec MPTCPns brctl stp br_tap1 on
sudo ip netns exec MPTCPns brctl stp br_tap2 on
