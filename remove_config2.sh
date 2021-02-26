#!/usr/bin/env bash

# Define number of UEs in the Non3GPP Test
NUM_UES=$2

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

sudo -v
if [ $? == 1 ]
then
    echo "Without root permission, you cannot run the test due to our test is using namespace"
    exit 1
fi

while getopts 'o' OPT;
do
    case $OPT in
        o) DUMP_NS=True;;
    esac
done
shift $(($OPTIND - 1))

GOPATH=$HOME/go
if [ $OS == "Ubuntu" ]; then
    GOROOT=/usr/local/go
elif [ $OS == "Fedora" ]; then
    GOROOT=/usr/lib/golang
fi
PATH=$PATH:$GOPATH/bin:$GOROOT/bin

UPFNS="UPFns"
EXEC_UPFNS="sudo ip netns exec ${UPFNS}"


###############
# Deleting state
###############

sleep 1
sudo killall -15 free5gc-upfd
sleep 1

if [ ${DUMP_NS} ]
then
    ${EXEC_UPFNS} kill -SIGINT ${TCPDUMP_PID}
fi

#cd ../..
mkdir -p testkeylog
for KEYLOG in $(ls *sslkey.log); do
    mv $KEYLOG testkeylog
done

sudo ip link del veth0
sudo ip netns del ${UPFNS}
sudo ip addr del 60.60.0.1/32 dev lo

if [[ "$1" == "TestI2catNon3GPP" ]]
then

    BRNAME="br0"
    VETH_N3IWF="veth_n3iwf"
    VETH_N3IWF_BRIDGE="veth_n3iwf_"$BRNAME

    sudo ip xfrm policy flush
    sudo ip xfrm state flush
    sudo ip link del $VETH_N3IWF
    sudo ip link del $VETH_N3IWF_BRIDGE
    sudo ip link del ipsec0
    sudo ifconfig $BRNAME down
    sudo brctl delbr $BRNAME

    for i in $(seq 1 $NUM_UES)
    do
      UENS="UEns_"$i
      EXEC_UENS="sudo ip netns exec ${UENS}"
      VETH_UE_BRIDGE="veth_ue_"$i"_"$BRNAME

      sudo ip link del $VETH_UE_BRIDGE
      ${EXEC_UENS} ip link del ipsec0
      sudo ip netns del ${UENS}
    done

    sudo killall n3iwf
    killall test.test
    cp -f config/amfcfg.conf.bak config/amfcfg.conf
    rm -f config/amfcfg.conf.bak
fi

sleep 2

#Deleting MPTCP netns
MPTCPNS="MPTCPns"
EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
sudo ip netns del ${MPTCPNS}
for i in $(seq 1 $NUM_UES)
do
  sudo ip link del "v_mph_"$i
  sudo ip link del "v_ueh_"$i
  sudo ip link set "brmptcp_"$i down
  sudo brctl delbr "brmptcp_"$i
done
