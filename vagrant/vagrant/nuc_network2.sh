#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

# Intel Wi-Fi 6 AX201 (already included in kernel>=5.2)
# NOTE: This driver is unstable in kernel 5.4 (it crashes frequently). It does not work correctly in kernel 5.6. In latest kernels (5.8, 5.9 and 5.10) the throughput (using iperf) highly decreases for TCP connections (maybe due to some modification on the TCP parameters?).
# As a conclusion, we will work using kernel 5.5, which has a robust driver and fast TCP connections. In addition, we have created a patch to include MPTCP functionality for this kernel.
sudo apt-get -y install wireless-tools dkms rfkill wpasupplicant

# Copy netplan configuration for both Ethernet and Wi-Fi
sudo cp $HOME/vagrant/NUC/ca.pem /etc/ssl/certs
sudo cp $HOME/vagrant/NUC/50-nuc.yaml.2 /etc/netplan/50-nuc.yaml
