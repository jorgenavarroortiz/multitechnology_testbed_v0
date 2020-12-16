#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y install wireless-tools dkms rfkill wpasupplicant

# Intel Gigabit Ethernet Controller I219-V
cp NUC/e1000e/e1000e-3.8.7.tar.gz $HOME
cd $HOME
tar zxf e1000e-3.8.7.tar.gz
cd e1000e-3.8.7/src
sudo make install

# Intel Wi-Fi 6 AX201
