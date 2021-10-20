#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

IFNAME='enp0s20f0u4'

phone_present=`ip a | grep ${IFNAME}: | wc -l`

if [[ ${phone_present} -eq 1 ]]; then
   echo "Phone present!"
   bIPADDR=`ifconfig enp0s20f0u4 | grep 'inet ' | cut -d" " -f 10 | wc -l`
   if [[ ${bIPADDR} -eq 1 ]]; then
      IPADDR=`ifconfig enp0s20f0u4 | grep 'inet ' | cut -d" " -f 10`
      NETMASK=`ifconfig enp0s20f0u4 | grep 'inet ' | cut -d" " -f 13`
      GW=`ip route | grep default | grep ${IFNAME} | cut -d" " -f 3`
      echo "Connected to phone (${GW}) using interface ${IFNAME} with IP address ${IPADDR} with netmask ${NETMASK}"
   else
      echo "Connected to phone using interface ${IFNAME} but no IP address has been assigned"
   fi
else
   echo "Phone not present!"
fi


