#!/bin/bash
# Using this script, the host will be able to ping the MPTCP proxy but not the CPE since frames will be tagged.
# CPE shall be configured with VLAN support (i.e. using OVS with access and trunk ports).

INTERFACE='eth1'

# Remove previous tagged interfaces (e.g. eth1.100, eth1.200, ...)
ifconfig | grep $INTERFACE | cut -d":" -f 1 | while read -r line ; do
  if [[ $line == $INTERFACE ]]; then
    echo "Interface $INTERFACE found!"
  else
    echo "Interface $line being removed"
    sudo ip link delete $line
#    sudo ifconfig $line down
  fi
done

# Create virtual interfaces
VLANID=100
sudo ip link add link ${INTERFACE} name ${INTERFACE}.${VLANID} type vlan id ${VLANID}
VLANID=200
sudo ip link add link ${INTERFACE} name ${INTERFACE}.${VLANID} type vlan id ${VLANID}
VLANID=300
sudo ip link add link ${INTERFACE} name ${INTERFACE}.${VLANID} type vlan id ${VLANID}

# Configure the real interface without IP address, and the virtual interface with an IP address from the VPN's pool
sudo ifconfig ${INTERFACE} 0 promisc up

VLANID=100
IPADDRESS=10.8.0.33
sudo ifconfig ${INTERFACE}.${VLANID} ${IPADDRESS}/24 promisc up
echo "Added VLAN ID ${VLANID} on interface ${INTERFACE}.${VLANID}"

VLANID=200
IPADDRESS=10.9.0.33
sudo ifconfig ${INTERFACE}.${VLANID} ${IPADDRESS}/24 promisc up
echo "Added VLAN ID ${VLANID} on interface ${INTERFACE}.${VLANID}"

VLANID=300
IPADDRESS=10.10.0.33
sudo ifconfig ${INTERFACE}.${VLANID} ${IPADDRESS}/24 promisc up
echo "Added VLAN ID ${VLANID} on interface ${INTERFACE}.${VLANID}"


# Configure routes
  # Removing default routes
echo "Removing default routes"
route -n > tmp.txt

awk '{ if ($1=="0.0.0.0") { print $2;} }' tmp.txt | while read -r line ; do
  echo "Removing default route through $line"
  sudo route del default gw $line
done

rm tmp.txt

# Policy-based routing, i.e. routing based on the source IP address
  # Route to first proxy
VLANID=100
IPADDRESS=10.8.0.33
GWIPADDRESS=10.8.0.1
sudo ip rule add from $IPADDRESS table ${VLANID}
sudo ip route add default via $GWIPADDRESS dev ${INTERFACE}.${VLANID} table ${VLANID}
  # Route to second proxy
VLANID=200
IPADDRESS=10.9.0.33
GWIPADDRESS=10.9.0.1
sudo ip rule add from $IPADDRESS table ${VLANID}
sudo ip route add default via $GWIPADDRESS dev ${INTERFACE}.${VLANID} table ${VLANID}
  # Route to third proxy
VLANID=300
IPADDRESS=10.10.0.33
GWIPADDRESS=10.10.0.1
sudo ip rule add from $IPADDRESS table ${VLANID}
sudo ip route add default via $GWIPADDRESS dev ${INTERFACE}.${VLANID} table ${VLANID}

#echo "Adding default route through gateway ${GATEWAY}"
#sudo route add default gw ${GATEWAY}
