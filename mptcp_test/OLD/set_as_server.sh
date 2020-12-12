#!/bin/bash

echo "Setting IP and name for server"
sudo cp config/50-vagrant.yaml.SERVER /etc/netplan/50-vagrant.yaml
sudo cp config/hostname.SERVER /etc/hostname
sudo cp config/hosts.SERVER /etc/hosts
echo "Remember to reboot to apply changes"
