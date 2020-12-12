# 5G-CLARITY testbed v0 setup

Testbed v0 (virtualized environment) for the 5G-CLARITY European Project. Initially started by Daniel Camps (from i2CAT). i2CAT's repository readme can be found below, after UGR's repository readme. Please contact Jorge Navarro-Ortiz (jorgenavarro@ugr.es) or Juan J. Ramos-Munoz (jjramos@ugr.es) for further details.

## Setting up the virtual environment

In order to simplify testing with MPTCP, we have developed two Vagrant configurations for the following **scenarios**:

1. **Two virtual machines** (VMs) which are **directly connected** by two network interfaces.

2. Three VMs for the scenario explained in the master branch (**UE <-> free5GC <-> proxy**). Within this scenario, we also consider the two testbeds considered in the main branch: simple testbed and free5GC testbed.

In both scenarios, a Vagrantfile has been developed to install the required kernel version, packages and the developed scripts, and will clone i2CAT's free5gc repository (master branch). So the deployed VMs should work out of the box. For details, please check the explanations in the master branch. **The developed installation scripts** (see the `vagrant` directory) **should work on real PCs** (as long as they have Intel architecture, e.g. Intel's NUC computers) **with few modifications**.

**Few differences with testbeds from the master branch**

- All functions related to MPTCP are included in the kernel, i.e. there is no need to load modules.
- **mptcpUe VM**: eth1 and eth2 are configured for using an internal network (ue_5gc) instead of using a bridged adapter. *The IP addresses of eth1 and eth2 are 10.1.1.1/24 and 10.1.1.2/24 instead of 10.0.1.1/24 and 10.0.1.2/24*. The reason is to avoid conflicts with eth0 (NAT interface, with IP 10.0.2.15/24) if we decide later to have eth1 and eth2 in different networks (which will become 10.0.1.0/24 and 10.0.2.0/24 in the original scenario). Additionally, *we added eth3 (with IP 192.168.33.1/24) to manage the VM through SSH*.
- **free5gc VM**: Similarly, eth1 has IP address 10.1.1.*222*/24, instead of 10.0.1.$(( NUM_UES + 1)). This is done to avoid confusion when using a different number of UEs in the mptcpUe VM, which will produce a different IP address at the free5gc VM. Additionally, *we added eth3 (with IP 192.168.33.2/24) to manage the VM through SSH*.
- **mptcpProxy VM**: *We only added eth2 (with IP 192.168.33.3/24) to manage the VM through SSH*.
- As usual, all VMs employ eth0 for Internet connection (through VirtualBox's NAT).

### VMs installation using Vagrant for scenario 1

Copy the content of the directory `free5gc/vagrant` to your computer. Rename the file `Vagrantfile.2machines` to `Vagrantfile`. **Copy your SSH credentials** for this repository (`id_rsa` and `id_rsa.pub` files) **to the `vagrant/ssh_credentials` directory**. Change to the directory with the `Vagrantfile` file and execute `vagrant up`. The execution will take around 15 minutes (depending on PC).

### VMs installation using Vagrant for scenario 2

Copy the content of the directory `free5gc/vagrant` to your computer. Rename the file `Vagrantfile.free5gc` to `Vagrantfile`. **Copy your SSH credentials** for this repository (`id_rsa` and `id_rsa.pub` files) **to the `vagrant/ssh_credentials` directory**. Change to the directory with the `Vagrantfile` file and execute `vagrant up`. The execution will take around 25 minutes (depending on PC).

**NOTE**: If you need to reconfigure your keyboard for your specific language, you can run `sudo dpkg-reconfigure keyboard-configuration` in the deployed VMs.

## Launching SCENARIO 1: Two virtual machines directly connected

In this scenario, two machines are directly connected using network interfaces eth1 and eth2. eth0 is configured with NAT in VirtualBox to connect to Internet. eth3 is configured with IP addresses 192.168.33.1/24 and 192.168.33.2/24 for management (for connecting through SSH). The image shows both VMs employing a network namespace (MPTCPns) and OpenVPN. You can configure whether namespaces or OpenVPN are used or not.

<img src="https://raw.githubusercontent.com/jorgenavarroortiz/5g-clarity_testbed_v0/main/img/mptcp_scenario1.png" width="800">

**Launching scenario 1 (without namespace/OpenVPN)**

To setup this scenario the following scripts have to be run in this order:

- In the machine `mptcpUe1` change to the directory `$HOME/free5gc/mptcp_test` and launch `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -g 10.1.1.3 -n 10.1.1 -u 2 -f 1`. You can add option `-d` if you want to read debug messages.

- In the machine `mptcpUe2` change to the directory `$HOME/free5gc/mptcp_test` and launch `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -g 10.1.1.1 -n 10.1.1 -u 2 -f 1`. You can add option `-d` if you want to read debug messages.

This will setup MPTCP properly in both VMs.

<img src="https://raw.githubusercontent.com/jorgenavarroortiz/5g-clarity_testbed_v0/main/img/mptcp_scenario1_set_MPTCP_parameters.png" width="1200">

In order to test the correct behaviour of MPTCP, you can run `iperf` and check the throughput in each interface using `ifstat`. For this, you can use:

- In the machine `mptcpUe2` (which will act as server) run `./test_throughput_tcp_server.sh & ifstat`.

- In the machine `mptcpUe1` (which will act as client) run `./test_throughput_tcp_client.sh -s 10.1.1.3 & ifstat`.

You can see that there are data sent on both interfaces (`eth1` and `eth2`).

<img src="https://raw.githubusercontent.com/jorgenavarroortiz/5g-clarity_testbed_v0/main/img/mptcp_scenario1_test_throughput.png" width="1200">

Additionally, you can check that each interface can be active (on), inactive (off) or used as backup (backup) on MPTCP. For that purpose, you can use the `change_interface_state.sh` script. In the following example, the test started with both interfaces as active, then 1) changing `eth2` to `backup` (so it would transfer data only if the other interface is inactive), next 2) changing `eth1` to `off` (so data was transferred using `eth2`), and finally 3) `eth1` becoming active again (so data was transferred only using `eth1`). Similarly, you can perform any other similar tests.

**IMPORTANT**: The `backup` state is only used with the `default` scheduler. In the case of the `roundrobin` scheduler, `backup` is treated as `on` (i.e. the interface remains active).

<img src="https://raw.githubusercontent.com/jorgenavarroortiz/5g-clarity_testbed_v0/main/img/mptcp_scenario1_change_interfaces_state.png" width="1200">

**Launching scenario 1 with namespace MPTCPns and OpenVPN**

To use a namespace (`MTPCPns`) and OpenVPN in both VMs, you have to run:

- In mptcpUe1: `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -g 10.1.1.3 -n 10.1.1 -u 2 -f 1 -m -o client`

- In mptcpUe2: `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -g 10.1.1.3 -n 10.1.1 -u 2 -f 3 -m -o server`

In order to perform some experiment, remember to use the namespace `MPTCPns` and its network interfaces. For simplicity, you can run `sudo ip netns exec MPTCPns bash`. In the namespace, you can check the network interfaces by executing `ifconfig` (you should have interfaces `v_mp_1` and `v_mp_2` for both MPTCP paths, with IP addresses 10.1.1.X/24, with X=1..4, and `tun0`, with IP address 10.8.0.1/24 on the server and 10.8.0.2/24 on the client).

<img src="https://raw.githubusercontent.com/jorgenavarroortiz/5g-clarity_testbed_v0/main/img/mptcp_scenario1_test_namespace_ovpn.png" width="800">

## Launching SCENARIO 2: UE <-> free5GC <-> proxy

In this scenario, a VM (mptcpUe) employs two network interfaces (`eth1` and `eth2`) emulating a computer with two wireless access technologies (WATs), e.g. Wi-Fi, Li-Fi or 5G NR. We assume that they are in bridge mode, i.e. connected to the same IP network. This VM is directly connected to a VM (free5gc) implementing the 5G core network. The connection is done through the N3IWF (Non-3GPP InterWorking Function) entity. Since we are employing MPTCP to simultaneously transfer data from both interfaces of mptcpUe VM, it is required that the other end also implements MPTCP. Due to the different kernel versions on both VMs (4.19.142 for MPTCP and 5.0.0-23 for free5GC), another VM (mptcpProxy) is also required. mptcpProxy implements MPTCP for this purpose.

**NOTE**: If required, you can add more network interfaces to the mptcpUe VM to emulate more WATs, as long as the last one is configured for management (i.e. using 192.168.33.1/24). The scripts will utilize consecutive network interfaces starting from eth1, eth2, eth3, etcetera.

**Launch scenario 2 without 5G core network**

The following image shows the scenario.

<img src="https://raw.githubusercontent.com/jorgenavarroortiz/5g-clarity_testbed_v0/main/img/mptcp_scenario2_simple.png" width="1200">

To setup this scenario the following scripts have to be run in this order:

- **mptcpProxy**: change to the `$HOME/free5gc/mptcp_test` directory and run `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -g 60.60.0.102 -n 60.60.0 -f 101 -o server`.

- **free5gc**: change to the `$HOME/go/src/free5gc/mptcp_test` directory and run `./configure_free5gc_simple.sh`.

- **mptcpUe**: change to the `$HOME/go/src/free5gc/mptcp_test` directory and run `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -g 10.1.1.222 -n 10.1.1 -u 2 -f 1 -m -o client`.

To test that MPTCP is working properly, run the following scripts:

- **mptcpProxy**: Check that there is a `tap0` interface by running `ifconfig`. Change to the `$HOME/free5gc/mptcp_test` directory and run `./test_throughput_tcp_server.sh`.

- **mptcpUe**: Enter into namespace MPTCPns by running `sudo ip netns exec MPTCPns bash`. Check that there is a `tap0` interface by running `ifconfig`. Then launch `./test_throughput_tcp_client.sh -c 10.8.0.1 & ifstat`. You can change the interfaces state by using the script `change_interface_state.sh`, e.g. `./change_interface_state.sh -i eth2 -s backup`, `./change_interface_state.sh -i eth1 -s off`, etcetera.

**Launch scenario 2 with 5G core network**

[**SCENARIO RUNNING FREE5GC: TO BE DONE AND WRITTEN**]

## Tools

[TO BE WRITTEN]

---

# 5GCLARITY testbed setup (from original repository)

## Setting up the virtual environment

After cloning this repository, you need to install vagrant and Virtualbox in your system. In `Vagrantfile` there is a configuration for an environment with three virtual machines named `mptcpUe`, implementing the logic of the 5GCLARITY CPE, `free5gc`, implementing the core network, and `mptcpProxy` implementing the logic of the mptcp proxy.
Run `vagrant up` inside this repository to bring up the machines.

The three machines will have a clean Ubuntu 18.04 installation. Vagrant will prepare an SSH server inside each VM, so you can ssh into them probably at porst `2222`, `2200` and `2201`.

You need to do the following additional configurations for the testbed:

- Machines `mptcpUe` and `mptpcProxy`
    - Compile the MPTCP kernel following the isntructions here: https://multipath-tcp.org/pmwiki.php/Users/DoItYourself.
    - Note: When compiling the kernel you need to do `make menuconfig` navigate to the Networking menu, and select all available mptcp path managers and mptcp schedulers. They are compiled as separate modules that can be loaded at runtime
    - Once the kernel is installed, reboot and check that you are running kernel `4.19.126`. This is the lates MPTCP kernel available at the time this testbed was setup.
    - Once the MPTCP kernel is available you need to clone again this repository in the VMs: `git clone ssh://git@bitbucket.i2cat.net:7999/sdwn/free5gc.git`
    - Install openvpn. There is no need to generate keys, as they are already provided in this repository

- Machine `mptcpUe`
    - In addition to the steps above, in this machine you need to install free5GC, but only the control plane functions (i.e. no need to compile UPF). To do this follow the instruction below in this Readme here: Install Control Plane Entities

- Machine `free5gc`
    - You need to do a full installation of free5GC. This requires installation of kernel `5.0.0-23-generic`, including the headers. This is required to compile the UPF, which requires a specific kernel module
    - You need to clone this repository again inside the VM: `git clone ssh://git@bitbucket.i2cat.net:7999/sdwn/free5gc.git`
    - After booting with the kernel `5.0.0-23-generic` follow the installation instructions for free5gc at the end of this readme

You can use the scripts in this repository to launch two testbeds:
- free5GC testbed, including a free5gC core, the MPTCP client and the proxy. This is detailed later
- Simple testbed, used to test MPTCP in a simpler setup without the free5GC core. Also detailed later

In a separate section we discuss some helper scripts to operate this testbed

## Launching the free5GC testbed

The goal is to set up the environment described in the following figure:

![Alt text](./img/testbed_setup.png?raw=true "free5GC testbed")

To setup this testbed the following scripts need to be run in this order:

- 1. In the machine `free5gc` launch the 5GCore
    - From this repo folder: `sudo ./clarity5gC.sh -n 2 -u -s 10.0.1`
    - Wait until verbose messages stop. Look inside `clarity5gC.sh` for an explanation on the parameters

- 2. In the machine `mptcpProxy` launch the openvpn server:
    - From this repo launch script `sudo ./clarityMptcpProxy.sh`
    - Wait until openvpn says the server is initialized
    - You may check that there is a `tap0` interface with IP address `10.8.0.1`

- 3. In the machine `mptcpUe` launch the UE that will attach to N3IWF through 2 interfaces, and launch an MPTCP namespace over which it will connect to the openvpn server
    - Form this repo launch script: `sudo ./clarityUe.sh -n 2 -m -a -s 10.0.1 -o 10.8.0.1`
    - Wait until verbose messages stop. Look inside `clarity5gC.sh` for an explanation on the parameters
    - You may see some `ERR` messages in the `free5gc` console while attaching the two UEs, you can ignore those
    - You may now ping over the openvpn connection from inside the MPTCP namespace: `sudo ip netns exec MPTCPns ping 10.8.0.1`

- What to do if openvpn does not connect?
    - First validate if you can ping from inside the MPTCP namespace in `mptcpUe` the DataNetwork in `mptpcProxy`:
      - In `mptcpUe`:
        - `sudo ip netns exec MPTCP ping -I v_mp_1 60.60.0.101`. Validate if path 1 is working
        - `sudo ip netns exec MPTCP ping -I v_mp_2 60.60.0.101`. Validate if path 1 is working
        - If above does not work validate if MPTCPns has a route towards `60.60.0/24`. This requires setup of Linux policy routing, which is done in the `clarityUe.sh` script and explained here: https://multipath-tcp.org/pmwiki.php/Users/ConfigureRouting
      - In `mptcpProxy`:
        - `ifconfig eth1`. Validate it has IP address `60.60.0.101` as sometimes Virtualbox reconfigures
        - `route -n`. Validate there is a route to `10.0.1/24` via `60.60.0.102` (c.f. grafic)
      - In `free5gc`:
        - `sudo ip netns exec UPFns route -n`. Validate UPF has one route towards `10.0.1/24` through device `upfgtp0` and one route to `60.60.0/24` through `veth_dn_u`
        - Validate IP forwarding is enabled in UPF namespace

- In order to clear the configuration there are a set of clear scripts that can be used in the different machines, e.g. 'clearClarity5gC.sh' to clear configuration in `free5gc` and `clearClarityUe.sh` to clear configuration in `mptcpUe`.

## Launching the simple testbed
The goal is to set up the environment described in the following figure:

![Alt text](./img/testbed_setup_simple.png?raw=true "simple testbed")

- 1. In the machine `free5gc` launch the 5GCore
    - From this repo folder: `sudo ./clarity5gC_simple.sh`

- 2. In the machine `mptcpProxy` launch the openvpn server:
    - From this repo launch script `sudo ./clarityMptcpProxy.sh`
    - Wait until openvpn says the server is initialized
    - You may check that there is a `tap0` interface with IP address `10.8.0.1`

- 3. In the machine `mptcpUe` launch the UE that will attach to N3IWF through 2 interfaces, and launch an MPTCP namespace over which it will connect to the openvpn server
    - Form this repo launch script: `sudo ./clarityUe_simple.sh -n 3 -m -a -s 10.0.1 -o 10.8.0.1`
    - You may now ping over the openvpn connection from inside the MPTCP namespace: `sudo ip netns exec MPTCPns ping 10.8.0.1`

- What to do if openvpn does not connect?
    - First validate if you can ping from inside the MPTCP namespace in `mptcpUe` the DataNetwork in `mptpcProxy`:
      - In `mptcpUe`:
        - `sudo ip netns exec MPTCP ping -I v_mp_1 60.60.0.101`. Validate if path 1 is working
        - `sudo ip netns exec MPTCP ping -I v_mp_2 60.60.0.101`. Validate if path 1 is working
        - `sudo ip netns exec MPTCP ping -I v_mp_3 60.60.0.101`. Validate if path 1 is working

- In order to clear the configuration there are a set of clear scripts that can be used in the different machines, e.g. 'clearClarity5gC.sh' to clear configuration in `free5gc` and `clearClarityUe.sh -n 3` to clear configuration in `mptcpUe`.

## Helper tools
The following helper tools are included:
- You can change the MPTCP scheduler in the machines `mptcpUe` or `mptcpProxy` doing: `sudo sysctl -w net.mptcp.mptcp_scheduler=default`, where scheduler can be `default`, `redundant` or `roundrobin`
- Use `sudo sysctl -a | grep mptcp` to see what is your current MPTCP configuration
- In machine `mptcpUe` you can use `sudo ./openvpn_mgr -m start -M` or `sudo ./openvpn_mgr -m stop -M` to start or stop the openvpn tunnel inside the MPTCP namespace in the UE. Note that you need to restart the tunnel every time you change the scheduler for it to have effect. The reason is that scheduler is considered when the TCP socket opens
- In the machine `mptcpUe` you can use `./delay_mgr -m add -i v_mph_1 -d 200ms` or `./delay_mgr -m remove -i v_mph_1 -d 200ms` to add or remove delay to a given interface

# APPENDIX: free5GC v3.0.0 Installation Guide

## Minimum Requirement
- Software
    - OS: Ubuntu 18.04 or later versions
    - gcc 7.3.0
    - Go 1.12.9 linux/amd64
    - QEMU emulator 2.11.1
    - kernel version 5.0.0-23-generic (MUST for UPF)

**Note: Please use Ubuntu 18.04 or later versions and go 1.12.9 linux/amd64**


You can use `go version` to check your current Go version.
```bash
- Hardware
    - CPU: Intel i5 processor
    - RAM: 4GB
    - Hard drive: 160G
    - NIC card: 1Gbps ethernet card

- Hardware recommended
    - CPU: Intel i7 processor
    - RAM: 8GB
    - Hard drive: 160G
    - NIC card: 10Gbps ethernet card
```

## Hardware Tested
There are no gNB and UE for standalone 5GC available in the market yet.


## Installation
### A. Pre-requisite

1. Required packages for control plane
    ```bash
    sudo apt -y update
    sudo apt -y install mongodb wget git
    sudo systemctl start mongodb
    ```
2. Required packages for user plane
    ```bash
    sudo apt -y update
    sudo apt -y install git gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev
    go get -u github.com/sirupsen/logrus
    ```

### B. Install Control Plane Entities

1. Go installation
    * If another version of Go is installed
        - Please remove the previous Go version
            - ```sudo rm -rf /usr/local/go```
        - Install Go 1.12.9
            ```bash
            wget https://dl.google.com/go/go1.12.9.linux-amd64.tar.gz
            sudo tar -C /usr/local -zxvf go1.12.9.linux-amd64.tar.gz
            ```
    * Clean installation
        - Install Go 1.12.9
             ```bash
            wget https://dl.google.com/go/go1.12.9.linux-amd64.tar.gz
            sudo tar -C /usr/local -zxvf go1.12.9.linux-amd64.tar.gz
            mkdir -p ~/go/{bin,pkg,src}
            echo 'export GOPATH=$HOME/go' >> ~/.bashrc
            echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
            echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc
            echo 'export GO111MODULE=off' >> ~/.bashrc
            source ~/.bashrc
            ```

2. Clone free5GC project in `$GOPATH/src`
    ```bash
    cd $GOPATH/src
    git clone https://github.com/free5gc/free5gc.git
    ```

    **In step 3, the folder name should remain free5gc. Please do not modify it or the compilation would fail.**
3. Run the script to install dependent packages
    ```bash
    cd $GOPATH/src/free5gc
    chmod +x ./install_env.sh
    ./install_env.sh

    Please ignore error messages during the package dependencies installation process.
    ```

4. Extract the `free5gc_libs.tar.gz` to setup the environment for compiling
    ```bash
    cd $GOPATH/src/free5gc
    tar -C $GOPATH -zxvf free5gc_libs.tar.gz
    ```
5. Compile network function services in `$GOPATH/src/free5gc` individually, e.g. AMF (redo this step for each NF), or
    ```bash
    cd $GOPATH/src/free5gc
    go build -o bin/amf -x src/amf/amf.go
    ```
    **To build all network functions in one command**
    ```bash
    ./build.sh
    ```


### C. Install User Plane Function (UPF)

1. Please check Linux kernel version if it is `5.0.0-23-generic`
    ```bash
    uname -r
    ```


    Get Linux kernel module 5G GTP-U
    ```bash
    git clone https://github.com/PrinzOwO/gtp5g.git
    cd gtp5g
    make
    sudo make install
    ```
2. Build from sources
    ```bash
    cd $GOPATH/src/free5gc/src/upf
    mkdir build
    cd build
    cmake ..
    make -j`nproc`
    ```
3. Run UPF library test (In directory: $GOPATH/src/free5gc/src/upf/build)
    ```bash
    sudo ./bin/testgtpv1
    ```

**Note: Config is located at** `$GOPATH/src/free5gc/src/upf/build/config/upfcfg.yaml
   `

## Configuration

### A. Configure SMF with S-NSSAI
1. Configure NF Registration SMF S-NSSAI in `smfcfg.conf`
```yaml
snssai_info:
- sNssai:
    sst: 1
    sd: 010203
  dnnSmfInfoList:
    - dnn: internet
- sNssai:
    sst: 1
    sd: 112233
  dnnSmfInfoList:
    - dnn: internet
```


### B. Configure Uplink Classifier (ULCL) information in SMF

1. Enable ULCL feature in `smfcfg.conf`
```yaml
    ulcl:true
```

2. Configure UE routing path in `uerouting.yaml`
```yaml
ueRoutingInfo:
  - SUPI: imsi-2089300007487
    AN: 10.200.200.101
    PathList:
      - DestinationIP: 60.60.0.101
        DestinationPort: 8888
        UPF: !!seq
          - BranchingUPF
          - AnchorUPF1

      - DestinationIP: 60.60.0.103
        DestinationPort: 9999
        UPF: !!seq
          - BranchingUPF
          - AnchorUPF2
```
:::info
* DestinationIP and DestinationPort will be the packet  destination.
* UPF field will be the packet datapath when it match the destination above.
:::



## Run

### A. Run Core Network
Option 1. Run network function service individually, e.g. AMF (redo this for each NF), or
```bash
cd $GOPATH/src/free5gc
./bin/amf
```

**Note: For N3IWF needs specific configuration in section B**

Option 2. Run whole core network with command
```
./run.sh
```

### B. Run N3IWF (Individually)
To run N3IWF, make sure the machine is equipped with three network interfaces. (one is for connecting AMF, another is for connecting UPF, the other is for IKE daemon)

We need to configure each interface with a suitable IP address.

We have to create an interface for IPSec traffic:
```bash
# replace <...> to suitable value
sudo ip link add ipsec0 type vti local <IKEBindAddress> remote 0.0.0.0 key <IPSecInterfaceMark>
```
Assign an address to this interface, then bring it up:
```bash
# replace <...> to suitable value
sudo ip address add <IPSecInterfaceAddress/CIDRPrefix> dev ipsec0
sudo ip link set dev ipsec0 up
```

Run N3IWF (root privilege is required):
```bash
cd $GOPATH/src/free5gc/
sudo ./bin/n3iwf
```

## Test
Start Wireshark to capture any interface with `pfcp||icmp||gtp` filter and run the tests below to simulate the procedures:
```bash
cd $GOPATH/src/free5gc
chmod +x ./test.sh
```
a. TestRegistration
```bash
(In directory: $GOPATH/src/free5gc)
./test.sh TestRegistration
```
b. TestServiceRequest
```bash
./test.sh TestServiceRequest
```
c. TestXnHandover
```bash
./test.sh TestXnHandover
```
d. TestDeregistration
```bash
./test.sh TestDeregistration
```
e. TestPDUSessionReleaseRequest
```bash
./test.sh TestPDUSessionReleaseRequest
```

f. TestPaging
```!
./test.sh TestPaging
```

g. TestN2Handover
```!
./test.sh TestN2Handover
```

h. TestNon3GPP
```bash
./test.sh TestNon3GPP
```

i. TestULCL
```bash
./test_ulcl.sh -om 3 TestRegistration
```

## Appendix A: OAM
1. Run the OAM server
```
cd webconsole
go run server.go
```
2. Access the OAM by
```
URL: http://localhost:5000
Username: admin
Password: free5gc
```
3. Now you can see the information of currently registered UEs (e.g. Supi, connected state, etc.) in the core network at the tab "DASHBOARD" of free5GC webconsole

**Note: You can add the subscribers here too**

## Appendix B: Orchestrator
Please refer to [here](https://github.com/free5gmano)

## Appendix C: IPTV
Please refer to [here](https://github.com/free5gc/IPTV)

## Appendix D: System Environment Cleaning
The below commands may be helpful for development purposes.

1. Remove POSIX message queues
    - ```ls /dev/mqueue/```
    - ```rm /dev/mqueue/*```
2. Remove gtp5g tunnels (using tools in libgtp5gnl)
    - ```cd ./src/upf/lib/libgtp5gnl/tools```
    - ```./gtp5g-tunnel list pdr```
    - ```./gtp5g-tunnel list far```
3. Remove gtp5g devices (using tools in libgtp5gnl)
    - ```cd ./src/upf/lib/libgtp5gnl/tools```
    - ```sudo ./gtp5g-link del {Dev-Name}```

## Appendix E: Change Kernel Version
1. Check the previous kernel version: `uname -r`
2. Search specific kernel version and install, take `5.0.0-23-generic` for example
```bash
sudo apt search 'linux-image-5.0.0-23-generic'
sudo apt install 'linux-image-5.0.0-23-generic'
sudo apt install 'linux-headers-5.0.0-23-generic'
```
3. Update initramfs and grub
```bash
sudo update-initramfs -u -k all
sudo update-grub
```
4. Reboot, enter grub and choose kernel version `5.0.0-23-generic`
```bash
sudo reboot
```
#### Optional: Remove Kernel Image
```
sudo apt remove 'linux-image-5.0.0-23-generic'
sudo apt remove 'linux-headers-5.0.0-23-generic'
```

## Appendix F: Program the SIM Card
Install packages:
```bash
sudo apt-get install pcscd pcsc-tools libccid python-dev swig python-setuptools python-pip libpcsclite-dev
sudo pip install pycrypto
```

Download PySIM
```bash
git clone git://git.osmocom.org/pysim.git
```

Change to pyscard folder and install
```bash
cd <pyscard-path>
sudo /usr/bin/python setup.py build_ext install
```

Verify your reader is ready

```bash
sudo pcsc_scan
```

Check whether your reader can read the SIM card
```bash
cd <pysim-path>
./pySim-read.py –p 0
```

Program your SIM card information
```bash
./pySim-prog.py -p 0 -x 208 -y 93 -t sysmoUSIM-SJS1 -i 208930000000003 --op=8e27b6af0e692e750f32667a3b14605d -k 8baf473f2f8fd09487cccbd7097c6862 -s 8988211000000088313 -a 23605945
```

You can get your SIM card from [**sysmocom**](http://shop.sysmocom.de/products/sysmousim-sjs1-4ff). You also need a card reader to write your SIM card. You can get a card reader from [**here**](https://24h.pchome.com.tw/prod/DCAD59-A9009N6WF) or use other similar devices.

## Trouble Shooting

1. `ERROR: [SCTP] Failed to connect given AMF    N3IWF=NGAP`

    This error occured when N3IWF was started before AMF finishing initialization. This error usually appears when you run the TestNon3GPP in the first time.

    Rerun the test should be fine. If it still not be solved, larger the sleeping time in line 110 of `test.sh`.

2. TestNon3GPP will modify the `config/amfcfg.conf`. So, if you had killed the TestNon3GPP test before it finished, you might need to copy `config/amfcfg.conf.bak` back to `config/amfcfg.conf` to let other tests pass.

    `cp config/amfcfg.conf.bak config/amfcfg.conf`

# Release Note
## v3.0.0
+ AMF
    + Support SMF selection at PDU session establishment
    + Fix SUCI handling procedure
+ SMF
    + Feature
        + ULCL by config
        + Authorized QoS
    + Bugfix
        + PDU Session Establishment PDUAddress Information
        + PDU Session Establishment N1 Message
        + SMContext Release Procedure
+ UPF:
    + ULCL feature
    + support SDF Filter
    + support N9 interface
+ OAM
    + Get Registered UE Context API
    + OAM web UI to display Registered UE Context
+ N3IWF
    + Support Registration procedure for untrusted non-3GPP access
    + Support UE Requested PDU Session Establishment via Untrusted non-3GPP Access
+ UDM
    + SUCI to SUPI de-concealment
    + Notification
        + Callback notification to NF ( in SDM service)
        + UDM initiated deregistration notification to NF ( in UECM service)

## v2.0.2
+ Add debug mode on NFs
+ Auto add Linux routing when UPF runs
+ Add AMF consumer for AM policy
+ Add SM policy
+ Allow security NIA0 and NEA0
+ Add handover feature
+ Add webui
+ Update license
+ Bugfix for incorrect DNN
+ Bugfix for NFs registering to NRF

## v2.0.1
+ Global
    + Update license and readme
    + Add Paging feature
    + Bugfix for AN release issue
    + Add URL for SBI in NFs' config

+ AMF
    + Add Paging feature
    + Bugfix for SCTP PPID to 60
    + Bugfix for UE release in testing
    + Bugfix for too fast send UP data in testing
    + Bugfix for sync with defaultc config in testing

+ SMF
    + Add Paging feature
    + Create PDR with FAR ID
    + Bugfix for selecting DNN fail handler

+ UPF
    + Sync config default address with Go NFs
    + Remove GTP tunnel by removing PDR/FAR
    + Bugfix for PFCP association setup
    + Bugfix for new PDR/FAR creating
    + Bugfix for PFCP session report
    + Bugfix for getting from PDR
    + Bugfix for log format and update logger version

+ PCF
    + Bugfix for lost field and method
