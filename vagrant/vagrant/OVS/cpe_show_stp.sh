#!/bin/bash

sudo ovs-appctl stp/show
echo ""
EXISTS=`brctl show | grep brmptcp_1 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo brctl showstp brmptcp_1; fi
echo ""
EXISTS=`brctl show | grep brmptcp_2 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo brctl showstp brmptcp_2; fi
echo ""
EXISTS=`brctl show | grep brmptcp_3 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo brctl showstp brmptcp_3; fi
echo ""

echo ""
EXISTS=`sudo ip netns exec MPTCPns brctl show | grep br_tap0 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo ip netns exec MPTCPns brctl showstp br_tap0; fi
echo ""
EXISTS=`sudo ip netns exec MPTCPns brctl show | grep br_tap1 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo ip netns exec MPTCPns brctl showstp br_tap1; fi
echo ""
EXISTS=`sudo ip netns exec MPTCPns brctl show | grep br_tap2 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo ip netns exec MPTCPns brctl showstp br_tap2; fi
