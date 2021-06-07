#!/bin/bash
# Using this script, the host will be able to ping the CPE but not the MPTCP proxy,
# since frames will be sent untagged.
# CPE shall be configured either with VLAN support or without VLAN support.

sudo ifconfig vboxnet0 10.8.0.33/24 promisc up
sudo ifconfig vboxnet0.100 down
