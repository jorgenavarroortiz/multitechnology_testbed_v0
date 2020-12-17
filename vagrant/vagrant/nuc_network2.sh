#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

# Intel Wi-Fi 6 AX201 (already included in kernel>=5.2)
sudo apt-get -y install wireless-tools dkms rfkill wpasupplicant

# Copy netplan configuration for both Ethernet and Wi-Fi
sudo cp $HOME/vagrant/NUC/ca.pem /etc/ssl/certs
sudo cp $HOME/vagrant/NUC/50-nuc.yaml.2 /etc/netplan/50-nuc.yaml
