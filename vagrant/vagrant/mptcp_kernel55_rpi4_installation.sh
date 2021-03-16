#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), University of Granada

#sudo apt-get -y update
#sudo apt-get -y install build-essential libncurses-dev bison flex

cd $HOME/vagrant/MPTCP_kernel5.5_RPi
sudo dpkg -i linux-image-5.5.19-v8+_5.5.19-v8+-1_arm64.deb
sudo dpkg -i linux-headers-5.5.19-v8+_5.5.19-v8+-1_arm64.deb
sudo dpkg -i linux-libc-dev_5.5.19-v8+-1_arm64.deb

#sudo apt-get -y install openvpn
