#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

# This script assumes the following scenarios:
#
# Scenario 1: direct connection between two machines: mptcpUe1 <-> mptcpUe2
# Scenario 2: mptcpUe <-> free5gc <-> mptcpProxy

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -p <path manager> -s <scheduler> -c <congestion control> -g <gateway> -n <network> [-u <num_UEs>] [-f <last_byte_first_UE>] [-m] [-o <server/client>] [-d]" 1>&2;
  echo ""
  echo "E.g. for mptcpProxy: $0 -p fullmesh -s default -c olia -g 60.60.0.102 -n 60.60.0      -f 101    -o server"
  echo "E.g. for mptcpUe:    $0 -p fullmesh -s default -c olia -g 10.1.1.222  -n 10.1.1  -u 2 -f 1   -m -o client -S 60.60.0.101";
  echo ""
  echo "       <path manager> ........... default, fullmesh, ndiffports, binder"
  echo "       <scheduler> .............. default, roundrobin, redundant"
  echo "       <congestion control> ..... reno, cubic, lia, olia, wvegas, balia, mctcpdesync"
  echo "       <gateway> ................ IP address of gateway for default route"
  echo "       <network> ................ 3 first bytes of IP addresses (SMF UE subnet (UE) or proxy subnet (proxy)"
  echo "       <num_UEs> ................ number of UEs (last byte of IP addresses from 1 to <num_UEs>)"
  echo "       <last_byte_ip_address> ... last byte of the first IP address (following IP addresses will be consecutive)"
  echo "       -m ....................... create namespace MPTCPns with virtual interfaces"
  echo "       -o ....................... create an OpenVPN connection, indicating if this entity is server or client"
  echo "       -S ....................... OVPN server IP address"
  echo "       -A ....................... attach to free5gc (only OVPN client)"
  echo "       -d ....................... print debug messages"
  exit 1;
}

# Default values
REAL_MACHINE=0
ns=0
LAST_BYTE_FIRST_UE=1
CURRENTDIR=`pwd`
echo "current directory: $CURRENTDIR"

while getopts ":p:s:c:g:n:u:f:mo:S:ad" o; do
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
    g)
      g=1
      GW=${OPTARG}
      echo "GW=${GW}"
      ;;
    n)
      n=1
      SMF_UE_SUBNET=${OPTARG}
      echo "SMF_UE_SUBNET="${SMF_UE_SUBNET}
      ;;
    u)
      u=1
      NUM_UES=${OPTARG}
      echo "NUM_UES="${NUM_UES}
      ;;
    f)
      f=1
      LAST_BYTE_FIRST_UE=${OPTARG}
      echo "LAST_BYTE_FIRST_UE="${LAST_BYTE_FIRST_UE}
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
    a)
        ATTACH=True
        echo "Attach to free5gc is enabled"
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

if [ -z "${p}" ] || [ -z "${s}" ] || [ -z "${c}" ] || [ -z "${g}" ] || [ -z "${n}" ] || [ -z "${f}" ]; then
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
    echo "CURRENTDIRPWD: $CURRENTDIR"
    cd $CURRENTDIR
    card=`sed ${i}'q;d' if_names.txt`
    echo "card(1): $card"
    IPcard=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))"/24"
    sudo ifconfig $card $IPcard
  done
fi

#GlobalEth="eth1"
echo "CURRENTDIR: $CURRENTDIR"
cd $CURRENTDIR
GlobalEth=`sed '1q;d' if_names.txt`
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
    echo "CURRENTDIR: $CURRENTDIR"
    cd $CURRENTDIR
    card=`sed ${i}'q;d' if_names.txt`
    echo "card(2): $card"
    IPcard=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))
    NETcard=$SMF_UE_SUBNET".0"
    netmaskcardbits=24
    GWcard=$GW
    NETcard=${NETcard}"/"${netmaskcardbits}
    if [[ $DEBUG == 1 ]]; then echo "[DEBUG] IPcard:   ${IPcard}"; fi
    if [[ $DEBUG == 1 ]]; then echo "[DEBUG] NETcard:  ${NETcard}"; fi
    if [[ $DEBUG == 1 ]]; then echo "[DEBUG] GWcard:   ${GWcard}"; fi

    sudo ip link set dev $card multipath on
  done

else

  if [ ${ATTACH} ]; then
    # Create and prepare per-UE namespaces
    for i in $(seq 1 $NUM_UES)
    do
      UENS="UEns_"$i
      EXEC_UENS="sudo ip netns exec ${UENS}"

      sudo ip netns add ${UENS}

      echo "CURRENTDIR: $CURRENTDIR"
      cd $CURRENTDIR
      card=`sed ${i}'q;d' if_names.txt`
      echo "card(3): $card"

      # Create bridge simulating L2 network
      BRNAME="br"$i
      sudo brctl addbr $BRNAME
      sudo ifconfig $card 0.0.0.0 up
      sudo brctl addif $BRNAME $card # adding host eth interface to the bridge

      VETH_UE="veth_ue_"$i
      VETH_UE_BRIDGE="veth_ue_"$i"_"$BRNAME
      sudo ip link add $VETH_UE type veth peer name $VETH_UE_BRIDGE
      sudo ip link set $VETH_UE up
      sudo ip link set $VETH_UE_BRIDGE up
      sudo brctl addif $BRNAME $VETH_UE_BRIDGE
      sudo ifconfig $BRNAME up

      sudo ip link set $VETH_UE netns ${UENS} # Send other end of the veth pair to the UE namespace

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

    # Run EAP attach for each UE
    # Core Network side on 192.168.13.2 needs to be up and running!
    for i in $(seq 1 $NUM_UES)
    do
      sleep 2
      UENS="UEns_"$i
      EXEC_UENS="sudo ip netns exec ${UENS}"
      IP=$(($i + 1))
      export VETH_UE_IP="192.168.127."$IP
      echo ""
      echo "###############"
      echo "###### Launching registration for UE "$i

      cd $GOPATH/src/free5gc/src/test
      ${EXEC_UENS} $GOROOT/bin/go test -UeIndex $i -v -vet=off -timeout 0 -run "TestI2catNon3GPP" -args noinit
    done
  fi

  # Using MPTCPns namespace
  sudo ip netns add ${MPTCPNS}

  # Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
  for i in $(seq 1 $NUM_UES)
  do
    if [[ $DEBUG == 1 ]]; then
      echo ""
      echo "Connecting MPTCP namespace to UE "$i
    fi
    if [ ${ATTACH} ]; then
      UENS="UEns_"$i
      EXEC_UENS="sudo ip netns exec ${UENS}"
      VETH_UE="v_ue_"$i
      VETH_UE_H="v_ueh_"$i
      sudo ip link add $VETH_UE type veth peer name $VETH_UE_H
    fi

    echo "CURRENTDIR: $CURRENTDIR"
    cd $CURRENTDIR
    card=`sed ${i}'q;d' if_names.txt`
    echo "card(4): $card"

    VETH_MPTCP="v_mp_"$i
    VETH_MPTCP_H="v_mph_"$i

    sudo ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H
    sudo ifconfig $card 0.0.0.0 up
    sudo brctl addbr "brmptcp_"$i
    if [ ${ATTACH} ]; then
      sudo brctl addif "brmptcp_"$i $VETH_UE_H
    else
      sudo brctl addif "brmptcp_"$i $card
    fi
    sudo brctl addif "brmptcp_"$i $VETH_MPTCP_H
    sudo ip link set $VETH_MPTCP_H up
    sudo ip link set "brmptcp_"$i up
    if [ ${ATTACH} ]; then
      sudo ip link set $VETH_UE netns ${UENS} # Send one end of the veth pair to the UE namespace
      $EXEC_UENS ip link set $VETH_UE up
    fi
    sudo ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
    $EXEC_MPTCPNS ip link set $VETH_MPTCP up
    if [ ${ATTACH} ]; then
      IP_UE=$SMF_UE_SUBNET"."$(($i + 2))"/24"
      IP_UE_SIMPLE=$SMF_UE_SUBNET"."$(($i + 2))
      $EXEC_UENS ip addr add $IP_UE dev $VETH_UE
      $EXEC_UENS sysctl -w net.ipv4.ip_forward=1
    fi
    #IP_MPTCP=$SMF_UE_SUBNET"."$i"/24"
    #IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
    IP_MPTCP=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))"/24"
    IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))
    NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"
    if [[ $DEBUG == 1 ]]; then echo "NET_IP_MPTCP${i}: ${NET_IP_MPTCP}"; fi
    GW_MPTCP=$GW
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
    echo "CURRENTDIR: $CURRENTDIR"
    cd $CURRENTDIR
    card=`sed ${i}'q;d' if_names.txt`
    echo "card(5): $card"
    IPcard=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))
    NETcard=$SMF_UE_SUBNET".0"
    GWcard=$GW
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
    IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$(( LAST_BYTE_FIRST_UE+i-1 ))
    NET_IP_MPTCP=$SMF_UE_SUBNET".0/24"
    GW_MPTCP=$GW
    echo "Information for interface ${i}..."
    echo "VETH_MPTCP: ${VETH_MPTCP}"
    echo "VETH_MPTCP_H: ${VETH_MPTCP_H}"
    echo "NET_IP_MPTCP: ${NET_IP_MPTCP}"
    echo "GW_MPTCP: ${GW_MPTCP}"

    # Adding a static route in the UPF to reach the MPTCP namespace
    # *** TO BE CHECKED ***
    #$EXEC_UPFNS route add -net $SMF_UE_SUBNET".0/24" dev upfgtp0

    # Create routing tables for each interface
    $EXEC_MPTCPNS ip rule add from $IP_MPTCP_SIMPLE table $i #2> /dev/null
    $EXEC_MPTCPNS ip route add $NET_IP_MPTCP dev $VETH_MPTCP scope link table $i #2> /dev/null
    $EXEC_MPTCPNS ip route add default via $GW_MPTCP dev $VETH_MPTCP table $i #2> /dev/null

    # Probably not needed...
    echo "CURRENTDIR: $CURRENTDIR"
    cd $CURRENTDIR
    card=`sed ${i}'q;d' if_names.txt`
    echo "card(6): $card"
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

    echo "CURRENTDIR: $CURRENTDIR"
    cd $CURRENTDIR
    cd ovpn-config-client

    # Automatically modify the configuration file according to the OVPN server IP address
    cp ovpn-client1.conf.GENERIC ovpn-client1.conf
    sed -i 's/SERVER_IP_ADDRESS/${OVPN_SERVER_IP}/' ovpn-client1.conf

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
    echo "CURRENTDIR: $CURRENTDIR"
    cd $CURRENTDIR
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
