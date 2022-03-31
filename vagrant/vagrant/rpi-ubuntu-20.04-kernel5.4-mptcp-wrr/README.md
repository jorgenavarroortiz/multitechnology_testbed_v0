## Kernel installation

To install one of the available kernels (see `pkg*` directories), change to that directory and execute:
```
sudo dpkg -i *.deb
```

However, it is possible that this version is older than the current kernel version. If that is the case, follow these steps to remove the previous kernel:

1) Check the installed kernels:
```
apt list linux-image*raspi
```
2) Get details on an installed kernel (e.g. linux-image-5.4.0-1056-raspi):
```
apt show linux-image-5.4.0-1056-raspi
```
3) Remove that version (**DO NOT REBOOT HERE!!!**):
```
sudo apt-get remove linux-image-5.4.0-1056-raspi --purge
```
4) **BEFORE REBOOTING, YOU HAVE TO INSTALL THE COMPILED CUSTOM KERNEL. If not, you will not be able to boot.**
```
cd ~/kbuild
sudo dpkg -i *.deb
sudo sync
sudo reboot
```
5) You can check that the custom kernel is executed:
```
sudo uname -r
```
6) You can put the new kernel on "hold" status to prevent auto-update (e.g. linux-image-5.4.0-1055-raspi):
```
echo "linux-image-5.4.0-1055-raspi hold" | sudo dpkg --set-selections
```
7) You can review dpkg status setting for linux-image:
```
dpkg --get-selections | grep "linux-image"
```

**TO DISABLE IPV6 (required for MPTCP)**, you can use the GRUB configuration (from https://pimylifeup.com/ubuntu-disable-ipv6/). To do so, edit the `/etc/default/grub` file and modify the following directives:
```
GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"
GRUB_CMDLINE_LINUX="ipv6.disable=1"
```
Then, execute `sudo update-grub` to update the GRUB.
