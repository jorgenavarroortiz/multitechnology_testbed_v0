#!/bin/bash
# Using this script, the host will be able to ping the CPE but not the MPTCP proxy since frames will be untagged
# (if CPE is configured with VLAN support, i.e. using OVS with access and trunk ports).

usage() {
  echo "Usage: $0 [-i <interface>] [-I <IP address from the VPN IP address pool>] [-h]" 1>&2;
  echo " E.g.: $0 -i eth1 -I 10.8.0.33 -G 10.8.0.1" 1>&2;
  exit 1;
}

while getopts ":i:I:G:h" o; do
    case "${o}" in
        i)
            i=1
            INTERFACE=${OPTARG}
#            echo "INTERFACE="$INTERFACE
            ;;
        I)
            I=1
            IPADDRESS=${OPTARG}
#            echo "IPADDRESS="$IPADDRESS
            ;;
        G)
            G=1
            GATEWAY=${OPTARG}
#            echo "GATEWAY="$GATEWAY
            ;;
        h)
            h=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${I}" ] || [ -z "${G}" ] || [[ $h == 1 ]]; then
    usage
fi


# Remove other tagged interfaces (e.g. eth1.100, eth1.200, ...)
ifconfig | grep $INTERFACE | cut -d":" -f 1 | while read -r line ; do
  if [[ $line == $INTERFACE ]]; then
    echo "Interface $INTERFACE found!"
  else
    echo "Interface $line being removed"
    sudo ip link delete $line
#    sudo ifconfig $line down
  fi
done

# Configure the real interface with an IP address from the VPN's pool
sudo ifconfig ${INTERFACE} ${IPADDRESS}/24 promisc up

echo "Removed VLANs on interface ${INTERFACE}, which now has IP ${IPADDRESS}"

# Configure routes
  # Removing default routes
echo "Removing default routes"
route -n > tmp.txt

awk '{ if ($1=="0.0.0.0") { print $2;} }' tmp.txt | while read -r line ; do
  echo "Removing default route through $line"
  sudo route del default gw $line
done

rm tmp.txt

echo "Adding default route through gateway ${GATEWAY}"
sudo route add default gw ${GATEWAY}

