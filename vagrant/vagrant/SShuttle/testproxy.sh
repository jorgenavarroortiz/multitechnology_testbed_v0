sudo sysctl -w net.ipv4.ip_forward=1
sudo route del default
sudo route add default gw 10.1.1.1
