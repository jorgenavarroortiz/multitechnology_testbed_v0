#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

IFTOCLIENT=`cat if_toclient.txt`

./ovs_remove_rule_access_port.sh -i tap0 -v 100 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap0 -v 200 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap0 -v 300 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap1 -v 100 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap1 -v 200 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap1 -v 300 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap2 -v 100 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap2 -v 200 2> /dev/null
./ovs_remove_rule_access_port.sh -i tap2 -v 300 2> /dev/null

./ovs_remove_rule_trunk_port.sh -i ${IFTOCLIENT} -v 100 2> /dev/null
./ovs_remove_rule_trunk_port.sh -i ${IFTOCLIENT} -v 200 2> /dev/null
./ovs_remove_rule_trunk_port.sh -i ${IFTOCLIENT} -v 300 2> /dev/null

sudo ovs-vsctl show
