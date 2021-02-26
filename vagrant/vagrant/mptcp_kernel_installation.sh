#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install build-essential libncurses-dev bison flex

cd $HOME/vagrant/MPTCP_kernel4.19
sudo dpkg -i linux-image-4.19.142-mptcp_4.19.142-mptcp-1_amd64.deb
sudo dpkg -i linux-headers-4.19.142-mptcp_4.19.142-mptcp-1_amd64.deb
sudo dpkg -i linux-libc-dev_4.19.142-mptcp-1_amd64.deb

sudo apt-get -y install openvpn
