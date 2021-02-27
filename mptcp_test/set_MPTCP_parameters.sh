#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -p <path manager> -s <scheduler> -c <congestion control> -f <filename> [-u <num_UEs>] [-m] [-o <server/client>] [-S <OVPN server IP address>] [-d]" 1>&2;
  echo ""
  echo "E.g. for mptcpProxy: $0 -p fullmesh -s default -c olia -f if_names.txt.scenario1_different_networks_UE1 -u 3 -m -o server"
  echo "E.g. for mptcpUe:    $0 -p fullmesh -s default -c olia -f if_names.txt.scenario1_different_networks_UE2 -u 3 -m -o client -S 10.1.1.1";
  echo ""
  echo "       <path manager> ........... default, fullmesh, ndiffports, binder"
  echo "       <scheduler> .............. default, roundrobin, redundant"
  echo "       <congestion control> ..... reno, cubic, lia, olia, wvegas, balia, mctcpdesync"
  echo "       <filename> ............... defines the interfaces to be used (one per line), with format <interface name> <IP address/netmask> <gateway IP address>"
  echo "       -m ....................... create namespace MPTCPns with virtual interfaces"
  echo "       -o ....................... create an OpenVPN connection, indicating if this entity is server or client"
  echo "       -S ....................... OVPN server IP address"
  echo "       -d ....................... print debug messages"
  exit 1;
}

# Default values
REAL_MACHINE=0
ns=0
LAST_BYTE_FIRST_UE=1

while getopts ":p:s:c:f:u:mo:S:d" o; do
  case "${o}" in
    p)
      p=1
      PATHMANAGER=${OPTARG}
      echo "PATHMANAGER="$PATHMANAGER
      ;;
    s)
      s=1
      SCHEDULER=${OPTARG}
      echo "SCHEDULER="$SCHEDULER
      ;;
    c)
      c=1
      CONGESTIONCONTROL=${OPTARG}
      echo "CONGESTIONCONTROL="${OPTARG}
      ;;
    f)
      f=1
      FILENAME=${OPTARG}
      echo "FILENAME="${OPTARG}
      ;;
    u)
      u=1
      NUM_UES=${OPTARG}
      echo "NUM_UES="${NUM_UES}
      ;;
    m)
      ns=1
      MPTCPNS="MPTCPns"
      EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
      echo "NAMESPACE=MPTCPns"
      ;;
    o)
        OVPN=1
        OVPN_ENTITY=${OPTARG}
        echo "Create an OpenVPN connection"
        ;;
    S)
        OVPN_SERVER_IP=${OPTARG}
        echo "OVPN server IP address"
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

#if [ -z "${p}" ] || [ -z "${s}" ] || [ -z "${c}" ] || [ -z "${f}" ] || [ -z "${u}" ] || [ -z "${OVPN}" ]; then
#  usage
#fi

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
# echo "Error: root permission is needed!"
# exit 1
#fi

GOPATH=$HOME/go
if [ $OS == "Ubuntu" ]; then
  GOROOT=/usr/local/go
elif [ $OS == "Fedora" ]; then
  GOROOT=/usr/lib/golang
fi
PATH=$PATH:$GOPATH/bin:$GOROOT/bin

##############################
# CONFIGURATION
##############################
#./configure.sh
if [[ $ns == 0 ]]; then
#  sudo ifconfig eth0 down
  for i in $(seq 1 $NUM_UES)
  do
#    card="eth"$i
    card=`sed ${i}'q;d' $FILENAME | cut -f 1 -d ' '`
#    IPcard=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))"/24"
    IPcard=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 1 -d '/'`
    MaskCard=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 2 -d '/'`
    sudo ifconfig $card ${IPcard}/${MaskCard}
  done
fi

#GlobalEth="eth1"
GlobalEth=`sed '1q;d' $FILENAME | cut -f 1 -d ' '`
GlobalGW=$GW

##############################
# SETTING MPTCP PARAMETERS
##############################

# Show MPTCP version
if [[ $DEBUG == 1 ]]; then
  echo ""; echo "[INFO] Show version and configuration parameters"
  sudo dmesg | grep MPTCP
fi

# Modify tunable variables
sudo sysctl -w net.mptcp.mptcp_enabled=1     # Default 1
sudo sysctl -w net.mptcp.mptcp_checksum=1    # Default 1 (both sides have to be 0 in order to disable this)
sudo sysctl -w net.mptcp.mptcp_syn_retries=3 # Specifies how often we retransmit a SYN with the MP_CAPABLE-option. Default 3
sudo sysctl -w net.mptcp.mptcp_path_manager=$PATHMANAGER
sudo sysctl -w net.mptcp.mptcp_scheduler=$SCHEDULER

# Congestion control
sudo sysctl -w net.ipv4.tcp_congestion_control=$CONGESTIONCONTROL

if [[ $ns == 0 ]]; then
  # Configure each interface (no namespaces)
  for i in $(seq 1 $NUM_UES)
  do
#    card="eth"$i
    card=`sed ${i}'q;d' $FILENAME | cut -f 1 -d ' '`

    sudo ip link set dev $card multipath on
  done

else
  # Using MPTCPns namespace
  sudo ip netns add ${MPTCPNS}

  # Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
  for i in $(seq 1 $NUM_UES)
  do
    if [[ $DEBUG == 1 ]]; then
      echo ""
      echo "Connecting MPTCP namespace to UE "$i
    fi

    card=`sed ${i}'q;d' $FILENAME | cut -f 1 -d ' '`

    VETH_MPTCP="v_mp_"$i
    VETH_MPTCP_H="v_mph_"$i

    sudo ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H
    sudo ifconfig $card 0.0.0.0 up
    sudo brctl addbr "brmptcp_"$i
    sudo brctl addif "brmptcp_"$i $card
    sudo brctl addif "brmptcp_"$i $VETH_MPTCP_H
    sudo ip link set $VETH_MPTCP_H up
    sudo ip link set "brmptcp_"$i up
    sudo ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
    $EXEC_MPTCPNS ip link set $VETH_MPTCP up

    IP_MPTCP_SIMPLE=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 1 -d '/'`
    MaskCard=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 2 -d '/'`
    IP_MPTCP=${IP_MPTCP_SIMPLE}"/"${MaskCard}
    GW_MPTCP=`sed ${i}'q;d' $FILENAME | cut -f 3 -d ' '`
    IFS=. read -r i1 i2 i3 i4 <<< $IP_MPTCP_SIMPLE
    IFS=. read -r xx m1 m2 m3 m4 <<< $(for a in $(seq 1 32); do if [ $(((a - 1) % 8)) -eq 0 ]; then echo -n .; fi; if [ $a -le $MaskCard ]; then echo -n 1; else echo -n 0; fi; done)
#    IFS=. read -r m1 m2 m3 m4 <<< "255.255.255.0"
    NET_IP_MPTCP_SIMPLE=`printf "%d.%d.%d.%d\n" "$((i1 & (2#$m1)))" "$((i2 & (2#$m2)))" "$((i3 & (2#$m3)))" "$((i4 & (2#$m4)))"`
    NET_IP_MPTCP=${NET_IP_MPTCP_SIMPLE}"/"${MaskCard}
    #IP_MPTCP=$SMF_UE_SUBNET"."$i"/24"
    #IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
#    IP_MPTCP=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))"/24"
#    IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))
#    NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"
    if [[ $DEBUG == 1 ]]; then echo "NET_IP_MPTCP${i}: ${NET_IP_MPTCP}"; fi
#    GW_MPTCP=$GW
    if [[ $DEBUG == 1 ]]; then echo "GW_MPTCP${i}: ${GW_MPTCP}"; fi
    $EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP
    $EXEC_MPTCPNS ifconfig $VETH_MPTCP mtu 1400   # done to avoid fragmentation which breaks ovpn setup
  done
fi

# Disable interfaces for MPTCP (eth0 = NAT connection in VMs, to be modified for real machines)
if [[ $REAL_MACHINE == 0 ]]; then
  sudo ip link set dev eth0 multipath off
fi

# Remove previous rules
for i in {32700..32765}; do sudo ip rule del pref $i 2>/dev/null ; done

if [[ $ns == 0 ]]; then
  # Configure each interface (no namespaces)
  for i in $(seq 1 $NUM_UES)
  do
    card=`sed ${i}'q;d' $FILENAME | cut -f 1 -d ' '`
    IPcard=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 1 -d '/'`
    MaskCard=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 2 -d '/'`
    GWcard=`sed ${i}'q;d' $FILENAME | cut -f 3 -d ' '`
    IFS=. read -r i1 i2 i3 i4 <<< $IPcard
    IFS=. read -r xx m1 m2 m3 m4 <<< $(for a in $(seq 1 32); do if [ $(((a - 1) % 8)) -eq 0 ]; then echo -n .; fi; if [ $a -le $MaskCard ]; then echo -n 1; else echo -n 0; fi; done)
#    IFS=. read -r m1 m2 m3 m4 <<< "255.255.255.0"
    NETcard=`printf "%d.%d.%d.%d\n" "$((i1 & (2#$m1)))" "$((i2 & (2#$m2)))" "$((i3 & (2#$m3)))" "$((i4 & (2#$m4)))"`
#    IPcard=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))
#    NETcard=$SMF_UE_SUBNET".0"
#    GWcard=$GW
    # Create routing tables for each interface
    if [[ $DEBUG == 1 ]]; then
      sudo ip rule add from $IPcard table $i
      sudo ip route add ${NETcard}/24 dev $card scope link table $i
      sudo ip route add default via $GWcard dev $card table $i
    else
      sudo ip rule add from $IPcard table $i 2> /dev/null
      sudo ip route add ${NETcard}/24 dev $card scope link table $i 2> /dev/null
      sudo ip route add default via $GWcard dev $card table $i 2> /dev/null
    fi
  done

  # Default route
  if [[ $DEBUG == 1 ]]; then
    sudo ip route add default scope global nexthop via $GlobalGW dev $GlobalEth
  else
    sudo ip route add default scope global nexthop via $GlobalGW dev $GlobalEth 2> /dev/null
  fi

  # Showing routing information
  if [[ $DEBUG == 1 ]]; then
    echo ""; echo "[INFO] Show rules"
    sudo ip rule show
    echo ""; echo "[INFO] Show routes"
    sudo ip route
    echo ""; echo "[INFO] Show routing table 1"
    sudo ip route show table 1
    echo ""; echo "[INFO] Show routing table 2"
    sudo ip route show table 2
  fi

else
  # Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
  for i in $(seq 1 $NUM_UES)
  do
    VETH_MPTCP="v_mp_"$i
    VETH_MPTCP_H="v_mph_"$i

    #IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
    IP_MPTCP_SIMPLE=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 1 -d '/'`
    MaskCard=`sed ${i}'q;d' $FILENAME | cut -f 2 -d ' ' | cut -f 2 -d '/'`
    IP_MPTCP=${IP_MPTCP_SIMPLE}"/"${MaskCard}
    GW_MPTCP=`sed ${i}'q;d' $FILENAME | cut -f 3 -d ' '`
    IFS=. read -r i1 i2 i3 i4 <<< $IP_MPTCP_SIMPLE
    IFS=. read -r xx m1 m2 m3 m4 <<< $(for a in $(seq 1 32); do if [ $(((a - 1) % 8)) -eq 0 ]; then echo -n .; fi; if [ $a -le $MaskCard ]; then echo -n 1; else echo -n 0; fi; done)
    NET_IP_MPTCP_SIMPLE=`printf "%d.%d.%d.%d\n" "$((i1 & (2#$m1)))" "$((i2 & (2#$m2)))" "$((i3 & (2#$m3)))" "$((i4 & (2#$m4)))"`
    NET_IP_MPTCP=${NET_IP_MPTCP_SIMPLE}"/"${MaskCard}

#    IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))
#    NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"
#    GW_MPTCP=$GW

    if [[ $DEBUG == 1 ]]; then
      echo "Information for interface ${i}..."
      echo "VETH_MPTCP: ${VETH_MPTCP}"
      echo "VETH_MPTCP_H: ${VETH_MPTCP_H}"
      echo "IP_MPTCP_SIMPLE: ${i1}.${i2}.${i3}.${i4}"
      echo "NETMASK: ${m1}.${m2}.${m3}.${m4}"
      echo "NET_IP_MPTCP: ${NET_IP_MPTCP}"
      echo "GW_MPTCP: ${GW_MPTCP}"
    fi

    # Create routing tables for each interface
    $EXEC_MPTCPNS ip rule add from $IP_MPTCP_SIMPLE table $i #2> /dev/null
    $EXEC_MPTCPNS ip route add $NET_IP_MPTCP dev $VETH_MPTCP scope link table $i #2> /dev/null
    $EXEC_MPTCPNS ip route add default via $GW_MPTCP dev $VETH_MPTCP table $i #2> /dev/null

    # Probably not needed...
    card=`sed ${i}'q;d' $FILENAME | cut -f 1 -d ' '`
    sudo ip link set dev $card multipath on
    sudo ip link set dev $VETH_MPTCP_H multipath on
    $EXEC_MPTCPNS ip link set dev $VETH_MPTCP multipath on
  done

  # Default route
  if [[ $DEBUG == 1 ]]; then
    $EXEC_MPTCPNS ip route add default scope global nexthop via $GlobalGW dev v_mp_1
  else
    $EXEC_MPTCPNS ip route add default scope global nexthop via $GlobalGW dev v_mp_1 2> /dev/null
  fi

  # Showing routing information
  if [[ $DEBUG == 1 ]]; then
    echo ""; echo "[INFO] Show rules"
    $EXEC_MPTCPNS ip rule show
    echo ""; echo "[INFO] Show routes"
    $EXEC_MPTCPNS ip route
    for i in $(seq 1 $NUM_UES)
    do
      echo ""; echo "[INFO] Show routing table $i"
      $EXEC_MPTCPNS ip route show table $i
    done
  fi
fi

# Create OpenVPN connection if required
if [[ $OVPN == 1 ]]; then
  if [[ $OVPN_ENTITY == "client" ]]; then
    # OpenVPN client
    if [[ $ns == 1 ]]; then
      EXEC_OVPN=$EXEC_MPTCPNS
    else
      EXEC_OVPN="sudo"
    fi

    cd ovpn-config-client

    # Automatically modify the configuration file according to the OVPN server IP address
    cp ovpn-client1.conf.GENERIC ovpn-client1.conf
    sed -i 's/SERVER_IP_ADDRESS/'${OVPN_SERVER_IP}'/' ovpn-client1.conf

    $EXEC_OVPN openvpn ovpn-client1.conf &

    # It is required to remove tap0 from the MPTCP interfaces pool.
    # Otherwise, it will start not working intermittently.
    sleep 5
    TAPIF=`$EXEC_OVPN ip link show | grep tap -m 1 | cut -d ":" -f 2 | tr -d " "`
    echo "TAPIF: $TAPIF"
    $EXEC_OVPN ip link set dev ${TAPIF} multipath off
  else
    # OpenVPN server
    if [[ $ns == 1 ]]; then
      EXEC_OVPN=$EXEC_MPTCPNS
    else
      EXEC_OVPN="sudo"
    fi
    cd ovpn-config-proxy
    $EXEC_OVPN openvpn ovpn-server.conf &

    # It is required to remove tap0 from the MPTCP interfaces pool.
    # Otherwise, it will start not working intermittently.
    sleep 5
    TAPIF=`$EXEC_OVPN ip link show | grep tap -m 1 | cut -d ":" -f 2 | tr -d " "`
    echo "TAPIF: $TAPIF"
    $EXEC_OVPN ip link set dev ${TAPIF} multipath off
  fi
fi
