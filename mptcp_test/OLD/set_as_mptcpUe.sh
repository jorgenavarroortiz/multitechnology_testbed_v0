#!/bin/bash

echo "Setting IP and name for mptcpUe"
sudo cp config/50-vagrant.yaml.MPTCPUE /etc/netplan/50-vagrant.yaml
sudo cp config/hostname.MPTCPUE /etc/hostname
sudo cp config/hosts.MPTCPUE /etc/hosts
echo "Remember to reboot to apply changes"
