#/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), 2021

sudo dpkg -i linux-image-5.5.19-v8+_5.5.19-v8+-4_arm64.deb
sudo dpkg -i linux-headers-5.5.19-v8+_5.5.19-v8+-4_arm64.deb
sudo dpkg -i linux-libc-dev_5.5.19-v8+-4_arm64.deb
tar xvfz boot_rpi_kernel55_mptcp.tar.gz
sudo cp boot/* /boot/
sudo cp boot/overlays/* /boot/overlays/
