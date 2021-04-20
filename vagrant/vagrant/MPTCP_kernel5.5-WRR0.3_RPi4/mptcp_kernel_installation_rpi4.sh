#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo dpkg -i linux-image-5.5.19-mptcp-wrr03_5.5.19-mptcp-wrr03-2_arm64.deb
sudo dpkg -i linux-headers-5.5.19-mptcp-wrr03_5.5.19-mptcp-wrr03-2_arm64.deb
sudo dpkg -i linux-libc-dev_5.5.19-mptcp-wrr03-2_arm64.deb
tar xvfz boot_rpi_kernel55_mptcp_wrr03.tar.gz
sudo cp boot/* /boot/
sudo cp boot/overlays/* /boot/overlays/
