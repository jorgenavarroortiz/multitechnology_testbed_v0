#!/bin/bash

# Configure 60.60.0.102/24 to eth2
#sudo ifconfig eth4 "60.60.0.102/24" up
sudo ifconfig eth2 "60.60.0.102/24" up

# Configure 10.0.1.4 at eth1
#sudo ifconfig eth1 "10.1.1.1/24" up
#sudo ifconfig eth2 "10.1.2.1/24" up
#sudo ifconfig eth3 "10.1.3.1/24" up
sudo ifconfig eth1 "10.0.1.4/24" up

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
