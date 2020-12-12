#!/bin/bash

echo "Setting IP and name for client"
sudo cp config/50-vagrant.yaml.CLIENT /etc/netplan/50-vagrant.yaml
sudo cp config/hostname.CLIENT /etc/hostname
sudo cp config/hosts.CLIENT /etc/hosts
echo "Remember to reboot to apply changes"
