#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install build-essential libncurses-dev bison flex

cd $HOME/vagrant/MPTCP0.96_kernel5.4.144_WRR05
sudo dpkg -i linux-image-5.4.144-mptcp-wrr05-5gclarity+_5.4.144-mptcp-wrr05-5gclarity+-2_amd64.deb
sudo dpkg -i linux-headers-5.4.144-mptcp-wrr05-5gclarity+_5.4.144-mptcp-wrr05-5gclarity+-2_amd64.deb
sudo dpkg -i linux-libc-dev_5.4.144-mptcp-wrr05-5gclarity+-2_amd64.deb

sudo apt-get -y install openvpn
