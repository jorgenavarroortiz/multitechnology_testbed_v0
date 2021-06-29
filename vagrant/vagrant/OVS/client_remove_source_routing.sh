#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

# Delete rules
for i in {32700..32765}; do
   sudo ip rule del pref $i 2>/dev/null
done

# Delete routing tables
sudo ip route flush table 100 2>/dev/null
sudo ip route flush table 200 2>/dev/null
sudo ip route flush table 300 2>/dev/null
