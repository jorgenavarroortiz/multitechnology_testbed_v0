#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install build-essential libncurses-dev bison flex

cd $HOME/vagrant/MPTCP_kernel5.5
sudo dpkg -i *

sudo apt-get -y install openvpn
