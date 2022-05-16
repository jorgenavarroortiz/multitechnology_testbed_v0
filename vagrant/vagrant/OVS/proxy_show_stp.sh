#!/bin/bash

EXISTS=`brctl show | grep toserver-br | wc -l`
if [[ $EXISTS == 1 ]]; then sudo brctl showstp toserver-br; fi
EXISTS=`brctl show | grep brmptcp_1 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo brctl showstp brmptcp_1; fi
EXISTS=`sudo ip net exec MPTCPns brctl show 2> /dev/null | grep br_tap0 | wc -l`
if [[ $EXISTS == 1 ]]; then sudo ip netns exec MPTCPns brctl showstp br_tap0; fi
