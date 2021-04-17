#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install git wget
sudo apt-get -y install iperf ifstat
sudo apt-get -y install build-essential libncurses-dev bison flex

# iproute-mptcp (required for command "ip link set dev <interface> multipath <off/on/backup>")
cd $HOME
git clone https://github.com/multipath-tcp/iproute-mptcp.git
cd iproute-mptcp
make
sudo make install
