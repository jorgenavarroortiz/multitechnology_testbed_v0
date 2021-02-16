#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install build-essential libncurses-dev bison flex

cd $HOME/vagrant/MPTCP_kernel5.5
sudo dpkg -i linux-image-5.5.0-mptcp_5.5.0-mptcp-1_amd64.deb
sudo dpkg -i linux-headers-5.5.0-mptcp_5.5.0-mptcp-1_amd64.deb
sudo dpkg -i linux-libc-dev_5.5.0-mptcp-1_amd64.deb

sudo apt-get -y install openvpn
