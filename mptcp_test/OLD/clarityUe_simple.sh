#!/usr/bin/env bash
#
# This script is used to setup a 5GClarity UE with 2 namespaces representing the WiFi and LiFi interfaces and one MPTCP namesapce to aggregate traffic over the 2 access networks
#
# Authors: Daniel Camps (daniel.camps@i2cat.net), Jorge Navarro (jorgenavarro@ugr.es)
# Copyright: i2CAT, University of Granada

#NUM_UES=2
#SMF_UE_SUBNET="10.1.1"

# CONFIGURATION (*** TO BE INCLUDED AS SCRIPT PARAMETERS ***)
PATHMANAGER=fullmesh   # default, fullmesh, ndiffports, binder
SCHEDULER=default      # default, roundrobin, redundant
CONGESTIONCONTROL=olia # reno cubic lia olia wvegas balia mctcpdesync

GW_LAST_BYTE="222"

#############################
# Parsing inputs parameters
#############################

usage() { echo "Usage: $0 [-n <NUM_UEs>] [-m] [-a] [-s <SmfUeSubnet>] [-o <OvpnServerAddress>]" 1>&2; exit 1; }

while getopts ":n:mas:o:d" o; do
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
        d)
            DEBUG=1
            echo "Include debug messages"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${t}" ] || [ -z "${n}" ]; then
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

#sudo -v
#if [ $? == 1 ]
#then
#    echo "Error: root permission is needed!"
#    exit 1
#fi

GOPATH=$HOME/go
if [ $OS == "Ubuntu" ]; then
    GOROOT=/usr/local/go
elif [ $OS == "Fedora" ]; then
    GOROOT=/usr/lib/golang
fi
PATH=$PATH:$GOPATH/bin:$GOROOT/bin

####################
# Configure MPTCP path manager
####################

# Show MPTCP version
echo ""; echo "[INFO] Show version and configuration parameters"
sudo dmesg | grep MPTCP

# Modify tunable variables
sudo sysctl -w net.mptcp.mptcp_enabled=1     # Default 1
sudo sysctl -w net.mptcp.mptcp_checksum=1    # Default 1 (both sides have to be 0 in order to disable this)
sudo sysctl -w net.mptcp.mptcp_syn_retries=3 # Specifies how often we retransmit a SYN with the MP_CAPABLE-option. Default 3
sudo sysctl -w net.mptcp.mptcp_path_manager=$PATHMANAGER
sudo sysctl -w net.mptcp.mptcp_scheduler=$SCHEDULER

# Congestion control
sudo sysctl -w net.ipv4.tcp_congestion_control=$CONGESTIONCONTROL

# Remove previous rules
for i in {32700..32765}; do sudo ip rule del pref $i 2>/dev/null ; done

# Configure each interface
for i in $(seq 1 $NUM_UES)
do
  # card information
  card="eth"$i
  IPcard=$SMF_UE_SUBNET"."$i
  NETcard=$SMF_UE_SUBNET".0/24"
  GWcard=$SMF_UE_SUBNET".222"

  # Create routing tables for each interface
  sudo ip rule add from $IPcard table $i 2> /dev/null
  sudo ip route add $NETcard dev $card scope link table $i 2> /dev/null
  sudo ip route add default via $GWcard dev $card table $i 2> /dev/null
done

# Default route for normal internet
GlobalEth="eth1"
GlobalGW=$SMF_UE_SUBNET".222"
sudo ip route add default scope global nexthop via $GlobalGW dev $GlobalEth 2> /dev/null

# Show routing tables
echo ""; echo "[INFO] Show rules"
sudo ip rule show
echo ""; echo "[INFO] Show routes"
sudo ip route
for i in $(seq 1 $NUM_UES)
do
  echo ""; echo "[INFO] Show routing table $i"
  sudo ip route show table $i
done

# Disable interfaces for MPTCP (eth0 = NAT connection, eth3 = connection with host OS)
sudo ip link set dev eth0 multipath off
sudo ip link set dev eth3 multipath off
for i in $(seq 1 $NUM_UES)
do
  card="eth"$i
  sudo ip link set dev $card multipath on
done

# OVPN
if [[ $OVPN ]]; then
  cd ${GOPATH}/src/free5gc/ovpn-config-client
  sudo openvpn ovpn-client1.conf &

  # It is required to remove tap0 from the MPTCP interfaces pool.
  # Otherwise, it will start not working intermittently.
  sleep 5
  TAPIF=`sudo ip link show | grep tap -m 1 | cut -d ":" -f 2 | tr -d " "`
  echo "TAPIF: $TAPIF"
  sudo ip link set dev ${TAPIF} multipath off
fi
