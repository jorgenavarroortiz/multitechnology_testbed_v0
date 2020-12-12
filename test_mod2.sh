#!/usr/bin/env bash


#############
# Parsing inputs parameters
usage() { echo "Usage: $0 [-t <Teststring>] [-n <NUM_UEs>] [-m] [-u] [-s <SmfUeSubnet>]" 1>&2; exit 1; }

while getopts ":t:n:mus:" o; do
    case "${o}" in
        n)
            NUM_UES=${OPTARG}
	    n=1
	    echo "NUM_UEs="$NUM_UES
            ;;
        t)
            TEST_STRING=${OPTARG}
            t=1
	    echo "TEST_STRING="$TEST_STRING
            ;;
	m)
            MPTCP=True
            echo "MPTCP mode is enabled"
	    ;;
	u)
            BUILD_UPF=True
            echo "Force UPF build"
	    ;;
	s)
            SMF_UE_SUBNET=${OPTARG}
            echo "UE Subnet configured in SMF="$SMF_UE_SUBNET
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

#######
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


#################
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


TEST_POOL="TestRegistration|TestServiceRequest|TestXnHandover|TestN2Handover|TestDeregistration|TestPDUSessionReleaseRequest|TestPaging|TestI2catNon3GPP"
if [[ ! "$TEST_STRING" =~ $TEST_POOL ]]
then
    echo "Usage: $0 [ ${TEST_POOL//|/ | } ]"
    exit 1
fi


GOPATH=$HOME/go
if [ $OS == "Ubuntu" ]; then
    GOROOT=/usr/local/go
elif [ $OS == "Fedora" ]; then
    GOROOT=/usr/lib/golang
fi
PATH=$PATH:$GOPATH/bin:$GOROOT/bin

###############
# Preparing the UPF
echo ""
echo "Preparing the UPF namespace ..."

UPFNS="UPFns"
EXEC_UPFNS="sudo ip netns exec ${UPFNS}"

export GIN_MODE=release

# Setup network namespace
sudo ip netns add ${UPFNS}

sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth0 up
sudo ip addr add 60.60.0.1 dev lo
sudo ip addr add 10.200.200.1/24 dev veth0
sudo ip addr add 10.200.200.2/24 dev veth0

sudo ip link set veth1 netns ${UPFNS}

${EXEC_UPFNS} ip link set lo up
${EXEC_UPFNS} ip link set veth1 up
${EXEC_UPFNS} ip addr add 60.60.0.101 dev lo
${EXEC_UPFNS} ip addr add 10.200.200.101/24 dev veth1
${EXEC_UPFNS} ip addr add 10.200.200.102/24 dev veth1

cd src/upf/build && ${EXEC_UPFNS} ./bin/free5gc-upfd -f config/upfcfg.test.yaml &
sleep 2

${EXEC_UPFNS} ip link set dev upfgtp0 mtu 1500

########################
# SMF Config file --> It is launched in TestCN
cp config/test/smfcfg.single.testI2cat.conf config/test/smfcfg.test.conf


###################
# Launching N3IWF
if [[ "$TEST_STRING" == "TestI2catNon3GPP" ]]
then

    # Create bridge simulating L2 network
    BRNAME="br0"
    sudo brctl addbr $BRNAME

    # Create the N3IWF veth pairs (one with the IP@, the other connected to the common bridge
    VETH_N3IWF="veth_n3iwf"
    VETH_N3IWF_BRIDGE="veth_n3iwf_"$BRNAME
    sudo ip link add $VETH_N3IWF type veth peer name $VETH_N3IWF_BRIDGE
    sudo ip addr add 192.168.127.1/24 dev $VETH_N3IWF
    sudo ip link set $VETH_N3IWF up
    sudo ip link set $VETH_N3IWF_BRIDGE up
    sudo brctl addif $BRNAME $VETH_N3IWF_BRIDGE

    # For each UE create the namespace and the veth pairs (one with the IP, the other connected to the common bridge
    for i in $(seq 1 $NUM_UES)
    do
      UENS="UEns_"$i
      EXEC_UENS="sudo ip netns exec ${UENS}"

      sudo ip netns add ${UENS}

      # Create the veth pair for the UE and attach one end to the common bridge
      VETH_UE="veth_ue_"$i
      VETH_UE_BRIDGE="veth_ue_"$i"_"$BRNAME
      sudo ip link add $VETH_UE type veth peer name $VETH_UE_BRIDGE
      sudo ip link set $VETH_UE up
      sudo ip link set $VETH_UE_BRIDGE up
      sudo brctl addif $BRNAME $VETH_UE_BRIDGE

      sudo ip link set $VETH_UE netns ${UENS} # Send other end of the veth pair to the UE namespace

      # Configure ipsec inside the UE namespace
      IP=$(($i + 1))
      VETH_UE_IP_MASK="192.168.127."$IP"/24"
      VETH_UE_IP="192.168.127."$IP
      ${EXEC_UENS} ip addr add $VETH_UE_IP_MASK dev $VETH_UE
      ${EXEC_UENS} ip link set lo up
      ${EXEC_UENS} ip link set $VETH_UE up
      ${EXEC_UENS} ip link add ipsec0 type vti local $VETH_UE_IP remote 192.168.127.1 key 5
      ${EXEC_UENS} ip link set ipsec0 up

      # Enable ip forwarding inside the UE namespaces which is required in the MPTCP case
      ${EXEC_UENS} sysctl -w net.ipv4.ip_forward=1

    done 

    # Bring up the L2 bridge and the ipsec side of the N3IWF
    sudo ip link set $BRNAME up
    sudo ip link add name ipsec0 type vti local 192.168.127.1 remote 0.0.0.0 key 5
    sudo ip addr add 10.0.0.1/24 dev ipsec0
    sudo ip link set ipsec0 up


    # Configuration
    cp -f config/amfcfg.conf config/amfcfg.conf.bak
    cp -f config/amfcfg.n3test.conf config/amfcfg.conf

    # Run CN
    echo ""
    echo "##############"
    echo "#### Preparing 5GCore control functions ..."
    cd src/test && $GOROOT/bin/go test -NumUes $NUM_UES -v -vet=off -timeout 0 -run TestI2catCN &
    sleep 10

    # Run N3IWF
    echo ""
    echo "##############"
    echo "#### Loading the N3IWF ..."
    cd src/n3iwf && sudo -E $GOROOT/bin/go run n3iwf.go &
    sleep 5

    # Run Test for each UE
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
      ${EXEC_UENS} $GOROOT/bin/go test -UeIndex $i -v -vet=off -timeout 0 -run $TEST_STRING -args noinit  # TODO potential problem regarding authentication of each UE (if duplicated)
    done

    ##################
    # MPTCP - Create a new namespace linked to each UE namespace where we will run MPTCP
    if [ ${MPTCP} ]
    then
      sleep 3
      echo ""
      echo "###############"
      echo "Preparing MPTCP namespace ..."
      MPTCPNS="MPTCPns"
      EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
      sudo ip netns add ${MPTCPNS}

      # Create veth_pair between the MPTCP namespace, and the UE namespace (UEs represent interfaces in this case)
      for i in $(seq 1 $NUM_UES)
      do
        echo ""
        echo "Connecting MPTCP namespace to UE "$i
        UENS="UEns_"$i
        EXEC_UENS="sudo ip netns exec ${UENS}"
        VETH_UE="v_ue_"$i
        VETH_UE_H="v_ueh_"$i
        VETH_MPTCP="v_mp_"$i
        VETH_MPTCP_H="v_mph_"$i
        sudo ip link add $VETH_UE type veth peer name $VETH_UE_H
        sudo ip link add $VETH_MPTCP type veth peer name $VETH_MPTCP_H
	sudo brctl addbr "brmptcp_"$i
	sudo brctl addif "brmptcp_"$i $VETH_UE_H
	sudo brctl addif "brmptcp_"$i $VETH_MPTCP_H
        sudo ip link set $VETH_UE_H up
        sudo ip link set $VETH_MPTCP_H up
        sudo ip link set "brmptcp_"$i up
        sudo ip link set $VETH_UE netns ${UENS} # Send one end of the veth pair to the UE namespace
        $EXEC_UENS ip link set $VETH_UE up
        sudo ip link set $VETH_MPTCP netns ${MPTCPNS} # Send other end of the veth pair to the MPTCP namespace
        $EXEC_MPTCPNS ip link set $VETH_MPTCP up
	IP_UE=$SMF_UE_SUBNET"."$(($i + 2))"/24"
	IP_MPTCP=$SMF_UE_SUBNET"."$i"/24"
	IP_UE_SIMPLE=$SMF_UE_SUBNET"."$(($i + 2))
	IP_MPTCP_SIMPLE=$SMF_UE_SUBNET"."$i
	$EXEC_UENS ip addr add $IP_UE dev $VETH_UE
	$EXEC_UENS echo 1 > /proc/sys/net/ipv4/ip_forward # enable IP forwarding in the UE namespace
	$EXEC_MPTCPNS ip addr add $IP_MPTCP dev $VETH_MPTCP

        #############
	# Adding a static route in the UPF to reach the MPTCP namespace
        $EXEC_UPFNS route add -net $SMF_UE_SUBNET".0/24" dev upfgtp0

        #############
        # Configure routing tables within MPTCP namespace --> packets with source IP $IP_MPTCP will get routed through a different interface $VETH_MPTCP
        $EXEC_MPTCPNS ip rule add from $IP_MPTCP_SIMPLE table $i # this rule forces packets coming with this IP address to be routed according to table $i
        $EXEC_MPTCPNS ip rule add oif $VETH_MPTCP table $i # this rule is forces local applications that bind to the interface (like ping -I $VETH_MPTCP) to be routed according to table $i
        $EXEC_MPTCPNS ip route add $SMF_UE_SUBNET".0/24" dev $VETH_MPTCP scope link table $i
        $EXEC_MPTCPNS ip route add default via $IP_UE_SIMPLE dev $VETH_MPTCP table $i
        #Adding default gateway through UEns_1
        if [ "$i" == "1" ]
        then
          $EXEC_MPTCPNS ip route add default scope global nexthop via $IP_UE_SIMPLE dev $VETH_MPTCP
        fi

      done
    fi

else
    cd src/test
    $GOROOT/bin/go test -v -vet=off -run $1
fi

