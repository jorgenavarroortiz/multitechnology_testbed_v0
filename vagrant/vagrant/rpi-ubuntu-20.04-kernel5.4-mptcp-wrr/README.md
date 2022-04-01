## Kernel installation

Tested with Ubuntu 20.04 for ARM64 (https://cdimage.ubuntu.com/releases/20.04.4/release/ubuntu-20.04.4-preinstalled-server-arm64+raspi.img.xz)

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

**TO DISABLE IPV6 (required for MPTCP)**, you can add `ipv6.disable=1` to the arguments in the /boot/cmdline.txt file, so it is removed from the kernel.

**NOTE**: You can mount the FAT partition of the SD card to modify the cmdline.txt file with the following commands:
```
sudo mount -t vfat -o uid=root /dev/mmcblk0p1 /mnt
sudo nano /mnt/cmdline.txt
sudo umount /mnt
```
