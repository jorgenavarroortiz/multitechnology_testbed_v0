#!/usr/bin/env bash
#
# This script is used to setup a 5GClarity UE with 2 namespaces representing the WiFi and LiFi interfaces and one MPTCP namesapce to aggregate traffic over the 2 access networks
#
# Author: Daniel Camps (daniel.camps@i2cat.net)
# Copyright: i2CAT
# Modified by Jorge Navarro (University of Granada, jorgenavarro@ugr.es)


#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 [-n <NUM_UEs>] [-m -P <path manager> -S <scheduler> -C <congestion control> -c <CWND limited>] [-a] [-s <SmfUeSubnet>] [-i <interface directly connected to the data network> -I <IP address of the interface connected to the data network>] [-o <OvpnServerAddress>] [-d] [-h]" 1>&2;

  echo ""
  echo "E.g.: $0 -n 2 -m -P fullmesh -S default -C olia -a -s 10.0.1 -o 60.60.0.101 -i eth4 -I 60.60.0.33/24"
  echo ""
  echo "       <path manager> ........... default, fullmesh, ndiffports, binder"
  echo "       <scheduler> .............. default, roundrobin, redundant"
  echo "       <congestion control> ..... reno, cubic, lia, olia, wvegas, balia, mctcpdesync"
  echo "       <CWND limited> ........... for roundrobin, whether the scheduler tries to fill the congestion window on all subflows (Y) or whether it prefers to leave open space in the congestion window (N) to achieve real round-robin (even if the subflows have very different capacities)"
  echo ""
  echo "       -d ....................... print debug messages"
  echo "       -h ....................... this help"
  echo ""
  echo "Please remember to update the file if_names.txt according to your needs. This file includes the names of the network interfaces that will be used for MPTCP (one row per interface)."
  exit 1;
}

# Default values
DEBUG=0
NUM_UES=2
MPTCP=True
PATHMANAGER="fullmesh"
SCHEDULER="default"
CONGESTIONCONTROL="olia"
CWNDLIMITED="Y"
ATTACH=True
SMF_UE_SUBNET="10.0.1"
OVPN=True
OVPN_SERVER_IP="60.60.0.101"
IDN=False
IFNAMEDN="eth4"
IPDN="60.60.0.33/24"

while getopts ":n:mP:S:C:c:as:o:i:I:dh" o; do
  case "${o}" in
    n)
      NUM_UES=${OPTARG}
      n=1
      echo "NUM_UEs="$NUM_UES
      ;;
    m)
      MPTCP=True
      echo "MPTCP mode is enabled"
      ;;
    P)
      p=1
      PATHMANAGER=${OPTARG}
      echo "PATHMANAGER="$PATHMANAGER
      ;;
    S)
      s=1
      SCHEDULER=${OPTARG}
      echo "SCHEDULER="$SCHEDULER
      ;;
    C)
      c=1
      CONGESTIONCONTROL=${OPTARG}
      echo "CONGESTIONCONTROL="${OPTARG}
      ;;
    c)
      w=1
      CWNDLIMITED=${OPTARG}
      echo "CWNDLIMITED="${OPTARG}
      ;;
    a)
      ATTACH=True
      echo "5GCore Attach is enabled"
      ;;
    s)
      t=1
      SMF_UE_SUBNET=${OPTARG}
      echo "UE Subnet configured in SMF="$SMF_UE_SUBNET
      ;;
    o)
      OVPN=True
      OVPN_SERVER_IP=${OPTARG}
      echo "MPTCP namespace will launch OpenVPN tunnel"
      ;;
    i)
      IDN=True
      IFNAMEDN=${OPTARG}
      echo "IFNAMEDN="$IFNAMEDN
      ;;
    I)
      IPDN=${OPTARG}
      echo "IPDN="$IPDN
      ;;
    d)
      DEBUG=1
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

if [[ $h == 1 ]]; then
  usage
fi

##############################
# Environment configuration
##############################

# Check OS
if [ -f /etc/os-release ]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$NAME
  VER=$VERSION_ID
else
  # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
  OS=$(uname -s)
  VER=$(uname -r)
  echo "This Linux version is too old: $OS:$VER, we don't support!"
  exit 1
fi

GOPATH=$HOME/go
if [ $OS == "Ubuntu" ]; then
  GOROOT=/usr/local/go
elif [ $OS == "Fedora" ]; then
  GOROOT=/usr/lib/golang
fi
PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# Check if it is executed as root (exit otherwise)
if [[ `id -u` != 0 ]]; then
  echo "Please execute this script as root!"
  exit 1
fi

##############################
# SETTING MPTCP PARAMETERS
##############################

# Show MPTCP version
if [[ $DEBUG == 1 ]]; then
  echo ""; echo "[INFO] Show version and configuration parameters"
  dmesg | grep MPTCP
fi

# Modify tunable variables
sysctl -w net.mptcp.mptcp_enabled=1     # Default 1
sysctl -w net.mptcp.mptcp_checksum=1    # Default 1 (both sides have to be 0 in order to disable this)
sysctl -w net.mptcp.mptcp_syn_retries=3 # Specifies how often we retransmit a SYN with the MP_CAPABLE-option. Default 3
sysctl -w net.mptcp.mptcp_path_manager=$PATHMANAGER
sysctl -w net.mptcp.mptcp_scheduler=$SCHEDULER

# Congestion control
sysctl -w net.ipv4.tcp_congestion_control=$CONGESTIONCONTROL

# CWND limited (only used if the scheduler is roundrobin)
echo $CWNDLIMITED | tee /sys/module/mptcp_rr/parameters/cwnd_limited

#########################################
# Create and prepare per-UE namespaces
#########################################

### ETHERNET (i=1) and WIFI (i=2) namespace
for i in $(seq 1 $NUM_UES)
do
  WIFI=0
  if (( $i == 2 )); then
    WIFI=1
  fi

  UENS="UEns_"$i
  EXEC_UENS="ip netns exec ${UENS}"

  if (( $WIFI == 0 )); then
    ip netns add ${UENS}
  fi

  # JNa: Generalize the name of the network interface using if_names.txt
  card=`sed ${i}'q;d' if_names.txt`
  echo "Interface: $card"

  if (( $WIFI == 0 )); then
    # Create bridge simulating L2 network
    BRNAME="br"$i
    brctl addbr $BRNAME
    ifconfig $card 0.0.0.0 up
    brctl addif $BRNAME $card # adding host eth interface to the bridge

    VETH_UE="veth_ue_"$i
    VETH_UE_BRIDGE="veth_ue_"$i"_"$BRNAME
    ip link add $VETH_UE type veth peer name $VETH_UE_BRIDGE
    ip link set $VETH_UE up
    ip link set $VETH_UE_BRIDGE up
    brctl addif $BRNAME $VETH_UE_BRIDGE
    ifconfig $BRNAME up

    ip link set $VETH_UE netns ${UENS} # Send other end of the veth pair to the UE namespace
  else
    VETH_UE=$card
#    iw phy phy0 set netns name ${UENS}
  fi

  # Configure ipsec inside the UE namespace
  IP=$(($i + 2))
  VETH_UE_IP_MASK="192.168.13."$IP"/24"
  VETH_UE_IP="192.168.13."$IP
  ${EXEC_UENS} ip addr add $VETH_UE_IP_MASK dev $VETH_UE
  ${EXEC_UENS} ip link set lo up
  ${EXEC_UENS} ip link set $VETH_UE up
  ${EXEC_UENS} ip link add ipsec0 type vti local $VETH_UE_IP remote 192.168.13.2 key 5
  ${EXEC_UENS} ip link set ipsec0 up

  # Enable ip forwarding inside the UE namespaces which is required in the MPTCP case
  ${EXEC_UENS} sysctl -w net.ipv4.ip_forward=1

done

######################################
# Run EAP attach for each UE
#
# Core Network side on 192.168.13.2 needs to be up and running!
######################################
if [ ${ATTACH} ]
then
  for i in $(seq 1 $NUM_UES)
  do
    sleep 2
    UENS="UEns_"$i
    EXEC_UENS="ip netns exec ${UENS}"
    IP=$(($i + 1))
    #export VETH_UE_IP="192.168.127."$IP
    export VETH_UE_IP="192.168.13."$IP
    echo ""
    echo "###############"
    echo "###### Launching registration for UE "$i

    cd $GOPATH/src/free5gc/src/test
    ${EXEC_UENS} $GOROOT/bin/go test -UeIndex $i -v -vet=off -timeout 0 -run "TestI2catNon3GPP" -args noinit
  done
fi

##################
# Prepare MPTCP namesapce
##################

if [ ${MPTCP} ]
then
  sleep 3
  echo ""
  echo "###############"
  echo "Preparing MPTCP namespace ..."
  MPTCPNS="MPTCPns"
  EXEC_MPTCPNS="ip netns exec ${MPTCPNS}"
  ip netns add ${MPTCPNS}

  # Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
  for i in $(seq 1 $NUM_UES)
  do
    echo ""
    echo "Connecting MPTCP namespace to UE "$i
    UENS="UEns_"$i
    EXEC_UENS="ip netns exec ${UENS}"
    VETH_UE="v_ue_"$i
    VETH_UE_H="v_ueh_"$i
    VETH_MPTCP="v_mp_"$i
    VETH_MPTCP_H="v_mph_"$i
    ip link add $VETH_UE type veth peer name $VETH_UE_H
    ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H
    brctl addbr "brmptcp_"$i
    brctl addif "brmptcp_"$i $VETH_UE_H
    brctl addif "brmptcp_"$i $VETH_MPTCP_H
    ip link set $VETH_UE_H up
    ip link set $VETH_MPTCP_H up
    ip link set "brmptcp_"$i up
    ip link set $VETH_UE netns ${UENS} # Send one end of the veth pair to the UE namespace
    $EXEC_UENS ip link set $VETH_UE up
    ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
    $EXEC_MPTCPNS ip link set $VETH_MPTCP up
    IP_UE=$SMF_UE_SUBNET"."$(($i + 2))"/24"
    IP_MPTCP=$SMF_UE_SUBNET"."$i"/24"
    IP_UE_SIMPLE=$SMF_UE_SUBNET"."$(($i + 2))
    IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
    $EXEC_UENS ip addr add $IP_UE dev $VETH_UE
    $EXEC_UENS echo 1 > /proc/sys/net/ipv4/ip_forward # enable IP forwarding in the UE namespace
    $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
    $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400 # done to avoid fragmentation which breaks ovpn setup

    #############
    # Adding a static route in the UPF to reach the MPTCP namespace
#    $EXEC_UPFNS route add -net $SMF_UE_SUBNET".0/24" dev upfgtp0

    #############
    # Configure routing tables within MPTCP namespace --> packets with source IP $IP_MPTCP will get routed through a different interface $VETH_MPTCP
    $EXEC_MPTCPNS ip rule add from $IP_MPTCP_SIMPLE table $i # this rule forces packets coming with this IP address to be routed according to table $i
    $EXEC_MPTCPNS ip rule add oif $VETH_MPTCP table $i # this rule is forces local applications that bind to the interface (like ping -I $VETH_MPTCP) to be routed according to table $i
    $EXEC_MPTCPNS ip route add $SMF_UE_SUBNET".0/24" dev $VETH_MPTCP scope link table $i
    $EXEC_MPTCPNS ip route add default via $IP_UE_SIMPLE dev $VETH_MPTCP table $i
    #Adding default gateway through UEns_1
    if [ "$i" == "1" ]; then
      $EXEC_MPTCPNS ip route add default scope global nexthop via $IP_UE_SIMPLE dev $VETH_MPTCP
    fi

  done

  # Interface directly connected to the data network (to mptcpProxy VM)
  # *** Check that MPTCP is True (currently we are assuming that) ***
  if [ ${IDN} == True ]; then
    i=$(($NUM_UES + 1))
    card=$IFNAMEDN
    MPTCPNS="MPTCPns"
    EXEC_MPTCPNS="ip netns exec ${MPTCPNS}"

    VETH_MPTCP="v_mp_"$i
    VETH_MPTCP_H="v_mph_"$i

    ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H
    ifconfig $card 0.0.0.0 up
    brctl addbr "brmptcp_"$i
    brctl addif "brmptcp_"$i $card
    brctl addif "brmptcp_"$i $VETH_MPTCP_H
    ip link set $VETH_MPTCP_H up
    ip link set "brmptcp_"$i up
    ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
    $EXEC_MPTCPNS ip link set $VETH_MPTCP up
    IP_MPTCP_SIMPLE=`echo $IPDN | cut -d "/" -f 1`
    MaskCard=`echo $IPDN | cut -d "/" -f 2`
    IP_MPTCP=$IPDN
    GW_MPTCP=$OVPN_SERVER_IP ## *** Currently we are assuming that this interface is directly connected to the OVPN server ***
    IFS=. read -r i1 i2 i3 i4 <<< $IP_MPTCP_SIMPLE
    IFS=. read -r xx m1 m2 m3 m4 <<< $(for a in $(seq 1 32); do if [ $(((a - 1) % 8)) -eq 0 ]; then echo -n .; fi; if [ $a -le $MaskCard ]; then echo -n 1; else echo -n 0; fi; done)
#    IFS=. read -r m1 m2 m3 m4 <<< "255.255.255.0"
    NET_IP_MPTCP_SIMPLE=`printf "%d.%d.%d.%d\n" "$((i1 & (2#$m1)))" "$((i2 & (2#$m2)))" "$((i3 & (2#$m3)))" "$((i4 & (2#$m4)))"`
    NET_IP_MPTCP=${NET_IP_MPTCP_SIMPLE}"/"${MaskCard}
    if [[ $DEBUG == 1 ]]; then echo "NET_IP_MPTCP${i}: ${NET_IP_MPTCP}"; fi
    if [[ $DEBUG == 1 ]]; then echo "GW_MPTCP${i}: ${GW_MPTCP}"; fi
    $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
    $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400   # done to avoid fragmentation which breaks ovpn setup

    # Create routing tables for each interface
    $EXEC_MPTCPNS ip rule add from $IP_MPTCP_SIMPLE table $i #2> /dev/null
    $EXEC_MPTCPNS ip route add $NET_IP_MPTCP dev $VETH_MPTCP scope link table $i #2> /dev/null
    $EXEC_MPTCPNS ip route add default via $GW_MPTCP dev $VETH_MPTCP table $i #2> /dev/null

    # Probably not needed...
    ip link set dev $card multipath on
    ip link set dev $VETH_MPTCP_H multipath on
    $EXEC_MPTCPNS ip link set dev $VETH_MPTCP multipath on
  fi

  # Launching OVPN tunnel over MPTCP
  if [ ${OVPN} ]; then
    sleep 5
    echo ""
    echo "Launching OVPN tunnel over MPTCP to transport L2 packets"
    echo ""
    cd $GOPATH/src/free5gc/ovpn-config-client  # openvpn needs to run from this folder

    # JNa: automatically modify the configuration file according to the OVPN server IP address
    cp ovpn-client1.conf.GENERIC ovpn-client1.conf
    sed -i 's/SERVER_IP_ADDRESS/'${OVPN_SERVER_IP}'/' ovpn-client1.conf

    $EXEC_MPTCPNS openvpn ovpn-client1.conf &

    #TODO: Add check to validate the tap0 interface is available
  fi
fi
