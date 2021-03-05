#!/usr/bin/env bash
#
# This script is used to setup a v5GC with N3IWF and UPF
#
# Author: Daniel Camps (daniel.camps@i2cat.net)
# Copyright: i2CAT
# Modified by Jorge Navarro-Ortiz (jorgenavarro@ugr.es)

# Starting to generalize...
IPtoDN="60.60.0.102/24"
DNNET="60.60.0/24"
IPSecN3IWF="192.168.13.2"

############################
# Parsing inputs parameters
############################

# Default values
NUM_UES=2
BUILD_UPF=True
SMF_UE_SUBNET="10.0.1"

usage() { echo "Usage: $0 [-n <NUM_UEs>] [-u] [-s <SmfUeSubnet>]" 1>&2; exit 1; }

while getopts ":n:us:h" o; do
    case "${o}" in
        n)
            NUM_UES=${OPTARG}
	    n=1
	    echo "NUM_UEs="$NUM_UES
            ;;
	u)
            BUILD_UPF=True
            echo "Force UPF build"
	    ;;
        s)
            t=1
            SMF_UE_SUBNET=${OPTARG}
            echo "UE Subnet configured in SMF="$SMF_UE_SUBNET
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

########################
# UPF configuration
########################

# Rebuilding UPF if needed
if [ ${BUILD_UPF} ]
then
  echo ""
  echo "Rebuilding UPF ..."
  GOPATH=$HOME/go
  cd $GOPATH/src/free5gc/src/upf
  cd build
  cmake ..
  make -j`nproc`
  cd /home/vagrant/go/src/free5gc
fi

# Fresh boot
# Check if the gtp5g module is loaded. We need it to run the upf
LOADED=`lsmod | grep gtp5g`
if [ "$LOADED" == "" ]; then
  echo ""
  echo "Loading gtp5g.ko ..."
  modprobe udp_tunnel
  insmod /home/vagrant/gtp5g/gtp5g.ko

  echo "Building control plane elements ..."
  /home/vagrant/go/src/free5gc/build.sh
  sleep 5
fi

#
# Preparing the UPF
echo ""
echo "Preparing the UPF namespace ..."

UPFNS="UPFns"
EXEC_UPFNS="sudo ip netns exec ${UPFNS}"

export GIN_MODE=release

# Setup network namespace
sudo ip netns add ${UPFNS}

# Prepare veth pairs to communicate with N3IWF over N3 interface
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth0 up
sudo ip addr add 10.200.200.1/24 dev veth0 # AMF binds to this address
sudo ip addr add 10.200.200.2/24 dev veth0

sudo ip link set veth1 netns ${UPFNS}

${EXEC_UPFNS} ip link set lo up
${EXEC_UPFNS} ip link set veth1 up
${EXEC_UPFNS} ip addr add 10.200.200.101/24 dev veth1
${EXEC_UPFNS} ip addr add 10.200.200.102/24 dev veth1

# Prepare veth pairs to communicate with Data Network
sudo ip link add veth_dn_h type veth peer name veth_dn_u
sudo ip link set veth_dn_h up
sudo ip link set veth_dn_u netns ${UPFNS}
${EXEC_UPFNS} ip link set veth_dn_u up
BRNAME="br_dn"
sudo brctl addbr $BRNAME
sudo ifconfig "eth2" 0.0.0.0 up
sudo brctl addif $BRNAME "eth2"
sudo brctl addif $BRNAME veth_dn_h
sudo ifconfig $BRNAME up

# Adding static routes to UE namespace and to Data network and enable IP forwarding
${EXEC_UPFNS} ip addr add $IPtoDN dev veth_dn_u
${EXEC_UPFNS} sysctl -w net.ipv4.ip_forward=1

cd src/upf/build && ${EXEC_UPFNS} ./bin/free5gc-upfd -f config/upfcfg.test.yaml &

sleep 2

# Adding route to mptcp namespace subnet
${EXEC_UPFNS} ip link set dev upfgtp0 mtu 1500
${EXEC_UPFNS} ip route add $SMF_UE_SUBNET"/24" dev upfgtp0
${EXEC_UPFNS} ip route del $DNNET dev upfgtp0

###################
# 5GC control plane configuration (AMF, SMF)
###################

# SMF Config file --> It is launched in TestI2CatCN
cp config/test/smfcfg.single.testI2cat.conf config/test/smfcfg.test.conf

# AMF Configuration --> It is launched in TestI2CatCN
cp -f config/amfcfg.conf config/amfcfg.conf.bak
cp -f config/amfcfg.n3test.conf config/amfcfg.conf


###################
# Launch core Network and N3IWF
###################

# Bring up ipsec side of the N3IWF
sudo ip link add name ipsec0 type vti local $IPSecN3IWF remote 0.0.0.0 key 5
sudo ip addr add 10.0.0.1/24 dev ipsec0
sudo ip link set ipsec0 up

# Run CN
echo ""
echo "##############"
echo "#### Preparing 5GCore control functions ..."
cd src/test && $GOROOT/bin/go test -NumUes $NUM_UES -v -vet=off -timeout 0 -run TestI2catCN &

sleep 10

# Run N3IWF
# Config file is located in $HOME/go/src/free5gc/n3iwfcfg.conf
echo ""
echo "##############"
echo "#### Loading the N3IWF ..."
cd src/n3iwf && sudo -E $GOROOT/bin/go run n3iwf.go &
