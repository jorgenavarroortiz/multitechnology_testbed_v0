#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

# Intel Gigabit Ethernet Controller I219/V
# Not required from kernel version >= 5.5 (commented here just in case)
#cp NUC/e1000e-3.8.7.tar.gz $HOME
#cd $HOME
#tar zxf e1000e-3.8.7.tar.gz
#cd e1000e-3.8.7/src
#sudo make install

sudo cp $HOME/vagrant/NUC/50-nuc.yaml.1 /etc/netplan/50-nuc.yaml
