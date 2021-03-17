#!/usr/bin/env bash
#
# Jorge Navarro (University of Granada, jorgenavarro@ugr.es)

# Check if it is executed as root (exit otherwise)
if [[ `id -u` != 0 ]]; then
  echo "Please execute this script as root!"
  exit 1
fi

# Wi-Fi namespace
i=2
UENS="UEns_"$i
EXEC_UENS="ip netns exec ${UENS}"
ip netns add ${UENS}

card=`sed ${i}'q;d' if_names.txt`
echo "Interface: $card"

# Connect the card to the Wi-Fi namespace
iw phy phy0 set netns name ${UENS}

# Connect to the Wi-Fi network
$EXEC_UENS "./nuc_connect_to_wifi.sh"
