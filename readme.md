# 5G-CLARITY testbed v0 setup

Testbed v0 (virtualized environment) for the 5G-CLARITY European Project. Based on Daniel Camps' work (from i2CAT), see https://bitbucket.i2cat.net/projects/SDWN/repos/free5gc/browse. Please contact Jorge Navarro-Ortiz (jorgenavarro@ugr.es) or Juan J. Ramos-Munoz (jjramos@ugr.es) for further details.

We have also included instructions to install MPTCP in NUC (Intel NUC 10 NUC10i7FNH) using kernel ~~5.4~~5.5, which supports the usage of the Intel Wi-Fi 6 AX201 module.

You can watch a [video](https://youtu.be/_7CiYgILo1g) showing how [scenario 1](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0#launching-scenario-1-two-virtual-machines-directly-connected) works.

You can watch a [video](https://youtu.be/AYZm-uw-ZXU) showing how [scenario 2](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0#launching-scenario-2-ue---free5gc---proxy) works.

## Setting up the virtual environment

In order to simplify testing with MPTCP, we have developed two Vagrant configurations for the following **scenarios**:

1. **Scenario 1: two virtual machines** (VMs) which are **directly connected** by two network interfaces.

2. **Scenario 2: three VMs** for the scenario explained in the master branch (**UE <-> free5GC <-> proxy**). Within this scenario, we also include the two testbeds considered in the main branch: simple testbed and free5GC testbed.

In both scenarios, a Vagrantfile has been developed to install the required kernel version, packages and the developed scripts (including i2CAT's free5gc repository). So the deployed VMs should work out of the box. For details, please check the explanations in the master branch. **The developed installation scripts** (see the `vagrant` directory) **should work on real PCs** (as long as they have Intel architecture and Ubuntu 18.04 Server 64-bit installed). This has been successfully tested on an Intel NUC 10 NUC10i7FNH, please check below the section `NUC installation`. For this purpose, we have added the file **if_names.txt** (on both the root and the mptcp_test directories) so that you can write which will be the network interface for each path, so it is not restricted to eth1, eth2, etcetera (default values since these are the names used for the VMs).

**Few differences with testbeds from i2CAT's repo**

- All functions related to MPTCP are included in the kernel, i.e. there is no need to load modules. Instead of using kernel 4.19 (which it is supported by the MPTCP version in https://www.multipath-tcp.org/), we have updated the MPTCP patch for kernel 5.4 to work with **kernel 5.5**. The main advantage is that kernel 5.5 *works properly in Intel's NUC* (i.e. *AX201 Wi-Fi6 network card* has been tested and works properly with this kernel, whereas it has some serious stability problems with kernel 5.4).
- **mptcpUe VM**: `eth1`, `eth2` and `eth3` are configured to use an internal network (ue_5gc) instead of using a bridged adapter. `eth4` is directly connected to the _mptcpProxy_ VM. Access to this VM is available through **SSH on port 12222**.
- **free5gc VM**: Similarly, this machine utilizes two internal networks (ue_5gc and 5gc_proxy) instead of using a bridged adapter. Access to this VM is available through **SSH on port 22222**.
- **mptcpProxy VM**: Similarly, this machine utilizes an internal network (5gc_proxy) instead of using a bridged adapter. Access to this VM is available through **SSH on port 32222**.

### Hardware and software requirements

Please use free5GC Stage 3 Installation Guide ([GitHub](https://github.com/free5gc/free5gc-stage-3)) as reference.

**Hardware requirements**

The scenario with free5gc is quite demanding. We have tested in two different computers:

- Desktop PC with an **Intel(R) Core(TM) i7-7820X CPU @ 3.60GHz and 32 GBs of RAM**: In general, the scenario works ok with two network interfaces (although sometimes AMF is deployed after N3IWF, which requires to restart the process). It also works ok with three network interfaces, although sometimes one of the network interfaces works intermitently.

- Laptop PC with an **Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz and 16 GBs of RAM**: Tested with two network interfaces. Most of the times, AMF is deployed after N3IWF in the first execution, so you need to cancel it (ctrl+C) and execute it again. It works ok most of the times during the second execution. Most of the times it works ok with two network interfaces.

The performance (in terms of throughput) is low in both cases (few hundreds of kbps).

**Vagrant requirements**

These vagrant files requires the installation of the Vagrant Reload Provisioner (https://github.com/aidanns/vagrant-reload). If you are using Ubuntu, you could follow these steps:

```
wget https://releases.hashicorp.com/vagrant/2.2.14/vagrant_2.2.14_x86_64.deb
sudo dpkg -i vagrant_2.2.14_x86_64.deb
sudo vagrant plugin install vagrant-reload
```

You can check the version with ```vagrant --version```.

**Virtualbox**

We have tested the following installations using Virtualbox 6.1 (more precisely, 6.1.18r142142). If you are using Ubuntu, you could follow these steps:

```
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb http://download.virtualbox.org/virtualbox/debian bionic contrib"

sudo apt update
sudo apt install virtualbox-6.1
```

You can check the version with ```vboxmanage --version```. Please remember to uninstall completely any previous Virtualbox 5.x installation, using ```dpkg -l | grep virtualbox``` and ```dpkg --purge <package_name>```.

### VMs installation using Vagrant for scenario 1

**IMPORTANT: Please make sure that you copy the SSH credentials that you use to access this repository (`id_rsa` and `id_rsa.pub` files) to the `vagrant/ssh_credentials` directory as commented below. If not, the installation will fail!**

Copy the content of the directory `free5gc/vagrant` to your computer. Rename the file `Vagrantfile.2machines` to `Vagrantfile`. **Copy your SSH credentials** for this repository (`id_rsa` and `id_rsa.pub` files) **to the `vagrant/ssh_credentials` directory**. Change to the directory with the `Vagrantfile` file and execute `sudo vagrant up`. The execution will take around 15 minutes (depending on PC).

### VMs installation using Vagrant for scenario 2

**IMPORTANT: Please make sure that you copy the SSH credentials that you use to access this repository (`id_rsa` and `id_rsa.pub` files) to the `vagrant/ssh_credentials` directory as commented below. If not, the installation will fail!**

Copy the content of the directory `free5gc/vagrant` to your computer. Rename the file `Vagrantfile.free5gc` to `Vagrantfile`. **Copy your SSH credentials** for this repository (`id_rsa` and `id_rsa.pub` files) **to the `vagrant/ssh_credentials` directory**. Change to the directory with the `Vagrantfile` file and execute `sudo vagrant up`. The execution will take around 25 minutes (depending on PC).

**NOTE**: If you need to reconfigure your keyboard for your specific language, you can run `sudo dpkg-reconfigure keyboard-configuration` in the deployed VMs.

## Launching SCENARIO 1: Two virtual machines directly connected

In this scenario, two machines are directly connected using network interfaces eth1, eth2 and eth3. eth0 is configured with NAT in VirtualBox to connect to Internet. They are accessible through SSH on ports 12222 and 22222, respectively. The image shows both VMs employing a network namespace (MPTCPns) and OpenVPN. You can configure whether namespaces and OpenVPN are used or not.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario1.png" width="800">

**Launching scenario 1 (without namespace/OpenVPN)**

To setup this scenario the following scripts have to be run in this order:

- In the machine `mptcpUe1` change to the directory `$HOME/free5gc/mptcp_test` and launch `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE1 -u 3`. You can add option `-d` if you want to read debug messages.

- In the machine `mptcpUe2` change to the directory `$HOME/free5gc/mptcp_test` and launch `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE2 -u 3 -m`. You can add option `-d` if you want to read debug messages.

**NOTE<sub>1</sub>**: if_names.txt.scenario1_same_network_UEX (X=1 or 2) utilizes IP addresses on the same network (1.1.1.{1,2,3}/24 for eth{1,2,3} on mptcpUE1, and 1.1.1.{4,5,6} for eth{1,2,3} on mptcpUE2), assuming that all network interfaces are connected to the same internal network (ue_ue). if_names.txt.scenario1_different_networks_UEX (X=1 or 2) utilizes IP addresses on different networks (1.1.{1,2,3}.1/24 for eth{1,2,3} on mptcpUE1, and 1.1.{1,2,3}.2/24 on eth{1,2,3} on mptcpUE2) assuming that network interfaces are connected to 3 different internal networks (ue_ue_X, X=1,2,3). This will simplify the usage of these scripts on real machines, which typically use different networks for each interface.

**NOTE<sub>2</sub>**: If you need a client connected with three paths to a server with 1 path, just use `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE2 -u 1 -m` on the machine `mptcpUe2`.

NOTE<sub>3</sub>: The OpenVPN configuration files on both server and client are now automatically adjusted.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario1_set_MPTCP_parameters.png" width="1200">

In order to test the correct behaviour of MPTCP, you can run `iperf` and check the throughput in each interface using `ifstat`. For this, you can use:

- In the machine `mptcpUe1` (which will act as server) run `./test_throughput_tcp_server.sh & ifstat`.

- In the machine `mptcpUe2` (which will act as client) run `./test_throughput_tcp_client.sh -s 10.1.1.1 & ifstat`.

You can see that there are data sent on both interfaces (`eth1` and `eth2`).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario1_test_throughput.png" width="1200">

Additionally, you can check that each interface can be active (on), inactive (off) or used as backup (backup) on MPTCP. For that purpose, you can use the `change_interface_state.sh` script. In the following example, the test started with both interfaces as active, then 1) changing `eth2` to `backup` (so it would transfer data only if the other interface is inactive), next 2) changing `eth1` to `off` (so data was transferred using `eth2`), and finally 3) `eth1` becoming active again (so data was transferred only using `eth1`). Similarly, you can perform any other similar tests.

**IMPORTANT**: The `backup` state is only used with the `default` scheduler. In the case of the `roundrobin` scheduler, `backup` is treated as `on` (i.e. the interface remains active).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario1_change_interfaces_state.png" width="1200">

**Launching scenario 1 with namespace MPTCPns and OpenVPN**

You can watch a [video](https://youtu.be/_7CiYgILo1g) showing how it works.

To use a namespace (`MTPCPns`) and OpenVPN in both VMs, you have to run:

- In mptcpUe1: `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE1 -u 3 -m -o server`

- In mptcpUe2: `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE2 -u 3 -m -o client -S 10.1.1.1`

In order to perform some experiments, remember to use the namespace `MPTCPns` and its network interfaces. For simplicity, you can run `sudo ip netns exec MPTCPns bash`. In the namespace, you can check the network interfaces by executing `ifconfig` (you should have interfaces `v_mp_1`, `v_mp_2` and `v_mp_3` for the three MPTCP paths, with IP addresses 10.1.1.X/24, with X=1..3 on the first machine and X=4..6 on the second machine, and `tun0`, with IP address 10.8.0.1/24 on the server and 10.8.0.2/24 on the client).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario1_test_namespace_ovpn.png" width="800">

## Launching SCENARIO 2: UE <-> free5GC <-> proxy

In this scenario, a VM (mptcpUe) employs three network interfaces (`eth1`, `eth2` and `eth4`) emulating a computer with three wireless access technologies (WATs), e.g. Wi-Fi, Li-Fi and 5G NR (directly connected to the _mptcpProxy_ VM since there is no gNB emulator to connect through UPF). We assume that they are in bridge mode, i.e. connected to the same IP network. This VM is directly connected to a VM (free5gc) implementing the 5G core network. The connection is done through the N3IWF (Non-3GPP InterWorking Function) entity. Since we are employing MPTCP to simultaneously transfer data from the three network interfaces of mptcpUe VM, it is required that the other end also implements MPTCP. Due to the different kernel versions on both VMs (~~4.19.142~~5.5 for MPTCP and 5.0.0-23 for free5GC), another VM (mptcpProxy) is also required. mptcpProxy implements MPTCP for this purpose.

**NOTE**: If required, you can add more network interfaces to the mptcpUe VM to emulate more WATs connected through N3IWF (currently three interfaces are added). The scripts will utilize consecutive network interfaces starting from eth1, eth2, eth3, etcetera.

The following image shows the scenario. You can watch a [video](https://youtu.be/AYZm-uw-ZXU) showing how it works.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario2_free5gc.png" width="1200">

To setup this testbed the following scripts need to be run in this order:

- **free5gc**: change to the `$HOME/go/src/free5gc` directory and run `sudo ./clarity5gC.sh -n 2 -u -s 10.0.1`. Wait until verbose messages stop. If it stops after "_### Creating UE context for UeImsi=..._" messages, stop it (ctrl-C) and launch it again. This might happen in low-power PCs, in which the N3IWF starts before AMF is fully deployed. It should stop after "_[N3IWF] Handle NG Setup Response_" message. Look inside `clarity5gC.sh` for an explanation on the parameters.

- **mptcpProxy**: change to the `$HOME/free5gc` directory and run `sudo ./clarityMptcpProxy.sh -i 60.60.0.101/24 -I eth1 -g 60.60.0.102 -P fullmesh -S default -C olia`. Wait until openvpn says the server is initialized. You may check that there is a `tap0` interface with IP address `10.8.0.1`.

- **mptcpUe**: to attach to N3IWF through 2 (or more) interfaces, and launch an MPTCP namespace over which it will connect to the openvpn server, change to the `$HOME/go/src/free5gc` directory and run `sudo ./clarityUe.sh -n 2 -m -P fullmesh -S default -C olia -a -s 10.0.1 -o 60.60.0.101` (for two paths through N3IWF) or run `sudo ./clarityUe.sh -n 2 -m -P fullmesh -S default -C olia -a -s 10.0.1 -o 60.60.0.101 -i eth4 -I 60.60.0.1/24` (for three paths, two through N3IWF and one directly connected to the _mptcpProxy_ VM). Wait until verbose messages stop. Look inside `clarityUe.sh` for an explanation on the parameters. 
 
**Validation**:

- You may now ping over the OpenVPN connection from inside the MPTCP namespace: `sudo ip netns exec MPTCPns ping 10.8.0.1`
- You may validate if you can ping from inside the MPTCP namespace in `mptcpUe` the DataNetwork in `mptpcProxy`, by running `sudo ip netns exec MPTCP ping -I v_mp_X 60.60.0.101`, where X=1,2 (for the case with two paths) or X=1,2,3 (for the case with three paths)
- You may validate if MPTCPns has a route towards `60.60.0/24`
- In mptcpProxy, you may validate that there is a route to `10.0.1/24` via `60.60.0.102` (`route -n`)
- In `free5gc`, you may validate that UPF has one route towards `10.0.1/24` through device `upfgtp0` and one route to `60.60.0/24` through `veth_dn_u` (`sudo ip netns exec UPFns route -n`). You may also validate that IP forwarding is enabled in UPF namespace.

In order to clear the configuration there are a set of clear scripts that can be used in the different machines, e.g. 'clearClarity5gC.sh' to clear configuration in `free5gc` and `clearClarityUe.sh` to clear configuration in `mptcpUe`.

## Tools

The following tools are included in the Vagrantfiles and can be useful to show information from experiments.

### Testing TCP latency

To test TCP latency, you could use MTR (https://github.com/traviscross/mtr). It is included in the Vagrantfiles.

We have included a script, `test_latency.sh`, that employs MTR with typical parameters and save results to a file.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/test_latency_tcp.png" width="800">

### Testing TCP throughput

To test TCP throughput, you could use `iperf`. We have included two scripts (`test_tcp_throughput_server.sh` and `test_tcp_throughput_client.sh`) for simplicity, which save the results.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/test_throughput_tcp.png" width="800">

Also we can use the command `ifstat`, which shows us the throughput for the different network interfaces in both directions.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/ifstat.png" width="400">

### Changing bandwidth and latency of a network interface

For that purpose, you could use `tc-netem`. We have included two scripts for changing these values (`set_bw_latency.sh`) and for resetting them (`reset_bw_latency.sh`).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/set_bw_latency.png" width="800">

Additionally, the following helper tools are included:

- In machine `mptcpUe` you can use `sudo ./openvpn_mgr -m start -M` or `sudo ./openvpn_mgr -m stop -M` to start or stop the openvpn tunnel inside the MPTCP namespace in the UE. Note that you need to restart the tunnel every time you change the scheduler for it to have effect. The reason is that scheduler is considered when the TCP socket opens-

- In the machine `mptcpUe` you can use `./delay_mgr -m add -i v_mph_1 -d 200ms` or `./delay_mgr -m remove -i v_mph_1 -d 200ms` to add or remove delay to a given interface.

### Capture and process PCAP trace

To capture several (but not all) interfaces, you can use tshark (please check script `pcap_capture.sh`).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/pcap_capture.png" width="600">

Later, you can process the captured trace file with MPTCPTRACE (https://github.com/multipath-tcp/mptcptrace) (please check script `pcap_process.sh`).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/pcap_process.png" width="400">

The results can be plotted with xplot.org. **NOTE**: Remember to redirect the DISPLAY to your IP address using `export DISPLAY='<IP address>:0.0'`.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/pcap_process_plot.png" width="800">

# TCP congestion window

TCP congestion window related information is local, i.e. it is not sent in TCP packets. It is possible to add events for TCP congestion window tracing using the `/sys/kernel/debug/tracing/events/tcp/tcp_probe` file. We have developed some scripts to ease this task.

First, you have to start TCP cwnd tracing using `tcp_probe_start.sh`. After the experiment, you have to stop TCP cwnd tracing and save the information to a file using `tcp_probe_stop.sh`.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/tcp_probe_start_stop.png" width="600">

Later, you can process (`tcp_probe_process.sh`) and plot (`tcp_probe_plot.sh`) the information that you have saved. The last script includes 3 types of plots: 1) congestion window and slow start threshold, 2) smooth RTT, and 3) sender and receiver advertised windows. For plotting, remember first to redirect the DISPLAY to your IP address using `export DISPLAY='<IP address>:0.0'`.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/tcp_probe_process_plot.png" width="800">

## NUC installation

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/nuc.png" width="512">

The installation scripts for testbed v0 can be used to setup MPTCP on an Intel's NUC computer (tested on [Intel NUC 10 NUC10i7FNH](https://www.intel.com/content/www/us/en/products/boards-kits/nuc/kits/nuc10i7fnh.html)). Please execute the following steps:

- Fresh install Ubuntu Server 18.04 (64-bit) on the NUC.
- Copy the `5g-clarity_testbed_v0/vagrant/vagrant` directory from this repository to `$HOME`, so it becomes `$HOME/vagrant`.
- Check that you have network connectivity. For that purpose, you may configure a YAML file at `/etc/netplan`. Please check `$HOME/vagrant/NUC/50-nuc.yaml.1` as an example.
- Install kernel 5.5 with MPTCP support and reboot:
```
cd $HOME/vagrant
bash ./mptcp_kernel55_installation.sh
sudo reboot
```
- After rebooting, the NUC will have kernel 5.5 (you should check it by executing `uname -r`) ~~but you will loose the driver for the Intel Gigabit Ethernet Controller I219-V. In order to install the driver (e1000e version 3.8.7) execute:~~ (this was for kernel 5.4, which has some stabiltiy problems for the Wi-Fi card; it is not required with kernel 5.5).
~~`cd $HOME/vagrant`~~
~~`bash ./nuc_network1.sh`~~
Modify your network settings in the file `/etc/netplan/50-nuc.yaml` and reboot. Please check that you have network connectivity again.
- In order to have Wi-Fi connectivity, execute:
```
cd $HOME/vagrant
bash ./nuc_network2.sh
```
This will modify again the file `/etc/netplan/50-nuc.yaml`, so you have to configure again network settings (for both Ethernet and Wi-Fi). The sample settings are for UGR's eduroam. Please check https://netplan.io/reference/ for reference.
- In order to copy this repository on the NUC, remember first to copy your SSH credentials to `$HOME/.ssh` and change their permissions (`sudo chmod 600 $HOME/.ssh/id_rsa`). Then, execute (first please make sure that you have network connectivity):
```
cd $HOME/vagrant
bash ./mptcp_installation.sh
bash ./go_installation.sh
source $HOME/.bashrc
bash ./free5gc_control_plane_installation.sh
```

Congratulations! With these steps, you should have the kernel and the packages available at the `mptcpUe` VM from testbed v0.

**NOTE**: The scripts from testbed v0 assumed `eth0` and `eth1` as the names of the network interfaces. The names in the NUC are `eno1` for Ethernet and `wlp0s20f3` for Wi-Fi. You may need to modify the scripts to use any interface names (see if_names.txt and related files).
