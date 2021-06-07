#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

#REALLY IMPORTANT: include mptcp with IPv6
#REALLY IMPORTANT: all VMs with all NICs in promisc mode (vboxmanage modifyvm mptcpUeX --nicpromiscY allow-all)

sudo apt-get -y install libtool

git clone https://github.com/openvswitch/ovs.git
cd ovs
./boot.sh
./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
#./configure --prefix=/usr --with-linux=/lib/modules/`uname -r`/build
make -j`nproc`
sudo make install
sudo make modules_install
