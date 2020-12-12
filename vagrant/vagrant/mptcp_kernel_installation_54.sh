#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install build-essential libncurses-dev bison flex

cd /home/vagrant/vagrant/MPTCP_kernel5.4
sudo dpkg -i linux-image-5.4.0-mptcp_5.4.0-mptcp-1_amd64.deb
sudo dpkg -i linux-headers-5.4.0-mptcp_5.4.0-mptcp-1_amd64.deb
sudo dpkg -i linux-libc-dev_5.4.0-mptcp-1_amd64.deb

sudo apt-get -y install openvpn
