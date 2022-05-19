#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install build-essential libncurses-dev bison flex

cd $HOME/vagrant/MPTCP_kernel5.5_WRR05
sudo dpkg -i *.deb

sudo apt-get -y install openvpn
