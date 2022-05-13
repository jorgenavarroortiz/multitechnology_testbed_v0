# Multi-technology testbed v0 setup

Multi-technology testbed v0 (virtualized environment). Based on Daniel Camps' work (from i2CAT), see https://bitbucket.i2cat.net/projects/SDWN/repos/free5gc/browse. Please contact Jorge Navarro-Ortiz (jorgenavarro@ugr.es) or Juan J. Ramos-Munoz (jjramos@ugr.es) for further details.

We have also included instructions to install MPTCP in NUC (Intel NUC 10 NUC10i7FNH) using kernel ~~5.45.5~~5.4.144 (*), which supports the usage of the Intel Wi-Fi 6 AX201 module.

(*) _We have some stability problems for the Wi-Fi card before with kernel 5.4, but it seems that it is now working properly. So, we returned to kernel 5.4 since it is the LTS version._

Similarly, it has also been tested (scenario 1, i.e. without free5gc) using a Raspberry Pi 4 with 4 GB with Raspberry OS (64 bits), based on kernel rpi-5.5.y with support for MPTCP.

You can find the patch for linux kernel 5.5 with MPTCP support in the [MPTCP_patches](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/tree/main/MPTCP_patches) directory. This patch has been submitted to the multipath-tcp.org mailing list following the instructions from [here](https://multipath-tcp.org/pmwiki.php/Developer/SubmitAPatch). Included as a new repo (https://github.com/jorgenavarroortiz/linux-kernel-5.5-mptcp) as suggested by the developers from multipath-tcp.org.

You can watch a [video](https://youtu.be/_7CiYgILo1g) showing how [scenario 1](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0#launching-scenario-1-two-virtual-machines-directly-connected) works.

You can watch a [video](https://youtu.be/AYZm-uw-ZXU) showing how [scenario 2](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0#launching-scenario-2-ue---free5gc---proxy) works.

You can watch a [video](https://user-images.githubusercontent.com/17797704/125672786-4ee5dcec-b28b-4b11-885f-fd782e0a948f.mp4) showing how the scenario with OVS and using several MPTCP proxies works. Please download the video first if it is not correctly displayed on your browser.

## Setting up the virtual environment

In order to simplify testing with MPTCP, we have developed two Vagrant configurations for the following **scenarios**:

1. **Scenario 1: two virtual machines** (VMs) which are **directly connected** by two network interfaces.

2. **Scenario 2: three VMs** for the scenario explained in the master branch (**UE <-> free5GC <-> proxy**). Within this scenario, we also include the two testbeds considered in the main branch: simple testbed and free5GC testbed.

In both scenarios, a Vagrantfile has been developed to install the required kernel version, packages and the developed scripts (including i2CAT's free5gc repository). So the deployed VMs should work out of the box. For details, please check the explanations in the master branch. **The developed installation scripts** (see the `vagrant` directory) **should work on real PCs** (as long as they have Intel architecture and Ubuntu 18.04 Server 64-bit installed). This has been successfully tested on an Intel NUC 10 NUC10i7FNH, please check below the section `NUC installation`. For this purpose, we have added the file **if_names.txt** (on both the root and the mptcp_test directories) so that you can write which will be the network interface for each path, so it is not restricted to eth1, eth2, etcetera (default values since these are the names used for the VMs).

**Few differences with testbeds from i2CAT's repo**

- All functions related to MPTCP are included in the kernel, i.e. there is no need to load modules. Instead of using kernel 4.19 (which it is supported by the MPTCP version in https://www.multipath-tcp.org/), we have updated the MPTCP patch for kernel 5.4 to work with **kernel 5.5**. ~~The main advantage is that kernel 5.5 *works properly in Intel's NUC* (i.e. *AX201 Wi-Fi6 network card* has been tested and works properly with this kernel, whereas it has some serious stability problems with kernel 5.4).~~ _Returned to kernel 5.4 (5.4.144)._
- **mptcpUe VM**: `eth1`, `eth2` and `eth3` are configured to use an internal network (ue_5gc) instead of using a bridged adapter. `eth4` is directly connected to the _mptcpProxy_ VM. Access to this VM is available through **SSH on port 12222**.
- **free5gc VM**: Similarly, this machine utilizes two internal networks (ue_5gc and 5gc_proxy) instead of using a bridged adapter. Access to this VM is available through **SSH on port 22222**.
- **mptcpProxy VM**: Similarly, this machine utilizes an internal network (5gc_proxy) instead of using a bridged adapter. Access to this VM is available through **SSH on port 32222**.

### Hardware and software requirements

Please use free5GC Stage 3 Installation Guide ([free5GC on GitHub](https://github.com/free5gc/free5gc-stage-3)) as reference.

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

- In the machine `mptcpUe2` change to the directory `$HOME/free5gc/mptcp_test` and launch `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE2 -u 3`. You can add option `-d` if you want to read debug messages.

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


IMPORTANT**: The `backup` state is only used with the `default` scheduler. In the case of the `roundrobin` scheduler, `backup` is treated as `on` (i.e. the interface remains active).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario1_change_interfaces_state.png" width="1200">

**Launching scenario 1 with namespace MPTCPns and OpenVPN**

You can watch a [video](https://youtu.be/_7CiYgILo1g) showing how it works.

To use a namespace (`MTPCPns`) and OpenVPN in both VMs, you have to run:

- In mptcpUe1: `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE1 -u 3 -m -o server`

- In mptcpUe2: `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE2 -u 3 -m -o client -S 10.1.1.1`

In order to perform some experiments, remember to use the namespace `MPTCPns` and its network interfaces. For simplicity, you can run `sudo ip netns exec MPTCPns bash`. In the namespace, you can check the network interfaces by executing `ifconfig` (you should have interfaces `v_mp_1`, `v_mp_2` and `v_mp_3` for the three MPTCP paths, with IP addresses 10.1.1.X/24, with X=1..3 on the first machine and X=4..6 on the second machine, and `tun0`, with IP address 10.8.0.1/24 on the server and 10.8.0.2/24 on the client).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_scenario1_test_namespace_ovpn.png" width="800">

**Launching scenario 1 with multiple proxies (OVPN servers) with different schedulers**

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/scenario1_2servers.png" width="800">

In order to create a scneario with several OVPN servers, you have two alternatives:

- If the VMs have to be deployed, change the value of the variable `VMS_COUNT` to the number of servers plus one (i.e. the client). Then, copy the if_names.txt.scenario1_same_network_UE1 to if_names.txt.scenario1_same_network_UEX (where X is the VM number, #VM) and modify the last byte of the IP addresses to 3 * #VM + 1, 3 * #VM + 2 and 3 * #VM + 3. We have already created these files for up to three servers plus one client (the last file), but it can be easily extended.

- If you have already deployed 2 VMs (mptcpUe1 and mptcpUe2), you can create one (or several) clone of e.g. mptcpUe1. Then, you will have to change the name to mptcpUeX (where X is #VM) (on VirtualBox but also within the VM, modifying the files /etc/hostname and /etc/hosts -> this is not required but it is more clear), forward TCP port X2222 to 22 (check the previous rule for SSH using `vboxmanage showvminfo mptcpUeX` which may be called `tcp12222`, remove the previous rule with `vboxmanage modifyvm mptcpUe3 --natpf1 delete <rule name>` and add a new rule using `vboxmanage modifyvm mptcpUeX --natpf1 "tcpX2222,tcp,127.0.0.1,X2222,,22"`) and modify the files commented on the previous bullet point.

To launch this scenario, e.g. with two servers, you can follow these steps:

- In the machine `mptcpUe1` (which will act as server with scheduler "default") run `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_UE1 -u 3 -m -o server -N 10.8.0.0`

- In the machine `mptcpUe2` (which will act as server with scheduler "roundrobin") run `./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_UE2 -u 3 -m -o server -N 10.9.0.0`

- In the machine `mptcpUe3` (which will act as client, with scheduler "default" for the connection to `mptcpUe1` and scheduler "roundrobin" for the connection to `mptcpUe2`) run `./set_MPTCP_parameters.sh -p fullmesh -s default -s roundrobin -c olia -f if_names.txt.scenario1_same_network_UE3 -u 3 -m -o client -S 10.1.1.1 -S 10.1.1.4`

The following image shows how iperf performs different to one server (10.8.0.1 using "default" scheduler) and to another server (10.9.0.1 using "roundrobin" scheduler).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/scenario1_twoservers.png" width="800">

**Launching scenario 1 with multiple proxies (OVPN servers) with different schedulers and using CPE as a switch and proxies as routers (_ip_forward=1_)**

![mptcp_vlan_ovs1](https://user-images.githubusercontent.com/17797704/136077467-59a7a5fd-d3ad-4d25-84bb-0a20f2d9b6d1.png)

Copy the content of the directory `free5gc/vagrant` to your computer. Rename the file `Vagrantfile.OVS` to `Vagrantfile`. **Copy your SSH credentials** for this repository (`id_rsa` and `id_rsa.pub` files) **to the `vagrant/ssh_credentials` directory**. Change to the directory with the `Vagrantfile` file and execute `sudo vagrant up`.

**NOTE** (18/9/2021): This Vagrantfile has been modified to use kernel 5.4.144 with MPTCP 0.96 and WRR 0.5. Other kernels in this repo utilize MPTCP 0.95. If required, you may modify the file Vagrantfile.OVS to select your preferred kernel.

This `Vagrantfile` generates 6 virtual machine: one client (IP address 33.3.3.33/24) connected to the CPE, which is connected to 3 MPTCP proxies, which in turn are connected to one server (IP address 66.6.6.33/24). If the client is connected to VLAN 100, data is sent over `proxy1` (default scheduler) to the server. If the client is connected to VLAN 200, data is sent over `proxy2` (Round-Robin scheduler) to the server. If the client is connected to VLAN 300, data is sent over `proxy3` (redundant scheduler) to the server.

**NOTE**: These virtual machines employ only 1GB of RAM in order to consume too much memory from the host machine. Feel free to change this if you have more resources.

In order to launch this scenario, please execute these commands in the following order:

- **proxy1** (accessible on localhost, port 22222):
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_proxy1 -u 1 -m -o server -N 10.8.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible.sh
```

- **proxy2** (accessible on localhost, port 32222):
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_proxy2 -u 1 -m -o server -N 10.9.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible.sh
```

- **proxy3** (accessible on localhost, port 42222):
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s redundant -c olia -f if_names.txt.scenario1_same_network_proxy3 -u 1 -m -o server -N 10.10.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible.sh
```

- **CPE** (accessible on localhost, port 12222):
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s default -s roundrobin -s redundant -c olia -f if_names.txt.scenario1_same_network_CPE -u 3 -m -o client -S 10.1.1.4 -S 10.1.1.5 -S 10.1.1.6
cd ~/vagrant/OVS
chmod 777 *.sh
./ovs_start.sh
./cpe_ovs_vlan.sh
./ovs_add_rule_trunk_port.sh -i eth4 -v 100 -v 200 -v 300
./ovs_add_rule_access_port.sh -i mtap0 -v 100
./ovs_add_rule_access_port.sh -i mtap1 -v 200
./ovs_add_rule_access_port.sh -i mtap2 -v 300
```

- **server** (accessible on localhost, port 62222):
```
cd ~/vagrant/OVS
chmod 777 *.sh
./server_routes.sh
```

- **client** (accessible on localhost, port 52222):
```
cd ~/vagrant/OVS
chmod 777 *.sh
```

If the client shall send its data through e.g. `proxy1` (or `proxy2` or `proxy3`) (which employs MPTCP default scheduler), its Ethernet frames shall be tagged with VLANID=100 (or 200 or 300). In a real deployment, a switch should be included between `client` and ``CPE`` using an access port with VLAN 100 (or 200 or 300) to the client and a trunk port with VLANs 100, 200 and 300 to the CPE.

```./client_tagged_vlan.sh -i eth1 -I 10.8.0.33 -G 10.8.0.1 -v 100```

Please test the correct behaviour using `ping -R 66.6.6.33`, which returns the path from `client` to `server`. It should go through the IP address of `proxy1` in the VPN (10.8.0.1).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_vlan_support1.png" width="800">

Data rate for the different paths (using Grafana and [Node exporter](https://github.com/prometheus/node_exporter) from [Prometheus](https://prometheus.io/)) using the default MPTCP scheduler:

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/MPTCP_grafana_default.png" width="1200">

Then, you may want to test sending data through ``proxy2`` (a clone of the ``client`` VM could be used, but we will change the VLAN ID used in order to avoid more VMs being executed). For that, execute:

``./client_tagged_vlan.sh -i eth1 -I 10.9.0.33 -G 10.9.0.1 -v 200``

Again, please test the correct behaviour using ``ping -R 66.6.6.33``. It should go through the IP address of ``proxy2`` in the VPN (10.9.0.1).

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/mptcp_vlan_support2.png" width="800">

Data rate for the different paths using the Round-Robin MPTCP scheduler:

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/MPTCP_grafana_roundrobin.png" width="1200">

Similarly, you can repeat the process for VLAN 300 and `proxy3` (10.10.0.33 for client, 10.10.0.1 as gateway).

Data rate for the different paths using the redundant MPTCP scheduler:

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/MPTCP_grafana_redundant.png" width="1200">

Additionally, it is possible to have three IP addresses on the `client`. To avoid creating new interfaces on the VM, three virtual interfaces are created on top of `eth1`. Each interface allows to communicate with the server through each of the proxies. To perform a test, execute:

``./client_tagged_several_vlans.sh``

Then, you can test that it works by executing `ping` and `iperf`. Each interface, with IP addresses 10.X.0.33/24 (X=8,9,10) can ping its corresponding proxy (10.X.0.1/24) and the server (66.6.6.33). For example, `ping -I 10.8.0.33 10.8.0.1` should work but `ping -I 10.8.0.33 10.9.0.1` should not. In addition, `ping -R -I 10.8.0.33 66.6.6.33` should show that the packet is routed through proxy1 (10.8.0.1). You can perform similar tests by using different interfaces (IP addresses) and destinations.

In order to test with `iperf`, you shall use the `-B` option on the CPE, specifying the IP address of the interface to be used. For example, you can execute `iperf -s` on the server and execute `iperf -c 66.6.6.33 -B 10.8.0.33` on the CPE. This data shall go through the proxy1 (you can check this with Grafana or using `tshark` on the corresponding `mtapX` interface (X=0,1,2)). As an example, the following picture shows an `iperf` test through proxy2 (which executes the Round-Robin scheduler).

![grafana_all_vlans_proxy2](https://user-images.githubusercontent.com/17797704/122924330-ee69c980-d365-11eb-9d9d-4ee0e49cb8d9.png)

Please note that, since ``CPE`` acts as a switch (executes OVS to add/remove the 802.1Q header), it cannot ping neither the client nor the proxies (using the IP addresses from the VPN pool). However, this is expected and the client can ping the proxies and the server.

**Launching scenario 1 with multiple proxies (OVPN servers) with different schedulers and using both CPE and proxies jointly as one switch**

This scenario is similar to the previous one, but it has some advantages:
- The CPE and the proxies can be seen as a black box, acting as a switch. That is, it is transparent for both the client and server, which are in the same network (e.g. IP address 66.6.6.22/24 for client and 66.6.6.33/24 for server).
- Since the client always connects with the same IP address, and CPE and proxies act as a layer 2 switch, the CPE can dinamically change which proxy (and therefore MPTCP scheduler) is being used at any moment. This allows us to change the MPTCP scheduler being used in real time during the same client's TCP session (e.g. one `iperf` experiment).

![mptcp_vlan_ovs](https://user-images.githubusercontent.com/17797704/136075063-5600cc32-f90b-49fd-9601-644c9b0f9963.png)

Steps to execute this scenario:

- **proxy1**:
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_proxy1 -u 1 -m -o server -N 10.8.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible.sh
./proxy_bridged_mode.sh
```

- **proxy2**:
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_proxy2 -u 1 -m -o server -N 10.9.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible.sh
./proxy_bridged_mode.sh
```

- **proxy3**:
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s redundant -c olia -f if_names.txt.scenario1_same_network_proxy3 -u 1 -m -o server -N 10.10.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible.sh
./proxy_bridged_mode.sh
```

- **CPE**:
```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s default -s roundrobin -s redundant -c olia -f if_names.txt.scenario1_same_network_CPE -u 3 -m -o client -S 10.1.1.4 -S 10.1.1.5 -S 10.1.1.6
cd ~/vagrant/OVS
chmod 777 *.sh
./ovs_start.sh
./cpe_ovs_vlan.sh
./ovs_remove_vlans.sh
./cpe_bridged_mode.sh
```

In order to modify the proxy being used for one specific IP, you can execute on the `CPE` (example for client with IP 66.6.6.22 selecting proxy 2, i.e. with WRR scheduler):
```
./cpe_configure_client.sh -s 66.6.6.22 -P 2
```

- **client**: no need to execute anything related to CPE or proxies (i.e. transparent for client), but being in the server's IP network
```
sudo ifconfig eth1 66.6.6.22/24
```

- **server**: no need to execute anything (i.e. transparent for server)

Once that the scenario is launched, you may test it using `iperf -s` on the server and `iperf -c 66.6.6.33 -t 100` on the client. Then, you may change the proxy for this particular client executing on the CPE `./cpe_configure_client.sh -s 66.6.6.22 -p X`, where X=1,2,3 is the specific proxy (1 for default scheduler, 2 for WRR scheduler and 3 for redundant scheduler). This can be done in real time within the same `iperf` session. An example is shown in the following figure. In this test, first the proxy 1 (default scheduler) is selected, being changed to proxy 2 (WRR scheduler) and finally to proxy 3 (redundant scheduler).

![image](https://user-images.githubusercontent.com/17797704/123972208-f0add280-d9ba-11eb-80c9-1be53351884e.png)

If you have intalled the repo for statistics (experimental, not included in this repo), you can execute (you may want to do it within a screen session, using e.g. `screen -S stats`):

```
cd ~/vagrant/stats/5g-clarity_testbed_v0_stats
./start_stats.sh
```

Then, you may connect to `http://<server IP address>:13000`.

Similarly, if you want to launch the REST API (uncomplete, only for testing purposes) you can execute (you may want to do it within a screen session, using e.g. `screen -S testapi`):

```
cd ~/vagrant/rest-api/app/cpe/
sudo python -m pipenv run uvicorn main:app --host 0.0.0.0 --port 8000
```

This test API includes calls to select a specific proxy, change a few parameters (e.g. WRR weigths, an additional artificial delay, etc), or to show/modify OVS flow entries. You may connect to `http://<server IP address>:18000`.

## Experiment with _OpenVPN_ acting both _CPE_ and _proxies_ as switches without namespaces (may be useful for testbeds with real equipment)

In this experiment we will employ an OpenVPN connection between _CPE_ and _proxy 1_, which will tunnel the connection between _client_ and _server_. _CPE_ and _proxy 1_ will employ the 5G-CLARITY scheduler. To launch this experiment, follow these steps:

- On _proxy 1_:

```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_same_network_proxy1 -u 1 -o server -N 10.8.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible_nons.sh
./proxy_bridged_mode_nons.sh
```

- On _proxy 2_:

```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_proxy2 -u 1 -o server -N 10.9.0.0
cd ~/vagrant/OVS/
chmod 777 *.sh
./proxy_externally_accessible_nons.sh
./proxy_bridged_mode_nons.sh
```


- On _CPE_:

```
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s default -s roundrobin -c olia -f if_names.txt.scenario1_same_network_CPE -u 3 -o client -S 10.1.1.4 -S 10.1.1.5
cd ~/vagrant/OVS
chmod 777 *.sh
./ovs_start.sh
./cpe_ovs_vlan_nons.sh
./ovs_remove_vlans_nons.sh
##./cpe_bridged_mode.sh
./cpe_configure_client.sh -s 66.6.6.22 -P 2 # To select proxy 2
./cpe_configure_client.sh -s 66.6.6.22 -P 1 # To select proxy 1
```

- On _server_:

```
iperf -s
```

- On _client_:

```
sudo ifconfig eth1 66.6.6.22/24
iperf -c 66.6.6.33
```

**NOTE**: Use `ifstat` on _CPE_ (and also on _proxies_) to check that the required interfaces (and only those) are transmitting data, i.e. all the paths are working.

**Launching scenario 1 with an SSH tunnel (_SShuttle_) instead of OpenVPN**

In this case, for simplicity, no namespaces are employed. This scenario is available if you use the ``Vagrantfile.ALL`` file (please rename it to ``Vagrantfile``).

![image](https://user-images.githubusercontent.com/17797704/137905634-a07f6f91-635c-4913-b27e-4439fce41411.png)

Steps to execute this scenario:

- **client**:
```
sudo route del default
sudo route add default gw 33.3.3.1
```

- **server**:
```
sudo route del default
sudo route add default gw 66.6.6.1
```

- **proxy1**:
```
sudo route del default
cd ~/free5gc/mptcp_test
sudo ip link set dev eth2 multipath off
./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_proxy1 -u 1
sudo sysctl -w net.ipv4.ip_forward=1
```

- **CPE**:
```
sudo route del default
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_CPE -u 3
cd vagrant/SShuttle
```

On the CPE, there are two alternatives. Using _SShuttle_ with NAT (only TCP) or with TProxy (both TCP and UDP). For _SShuttle_ with NAT, please execute ``./cpe_sshuttle_nat_onlytcp.sh``. For SShuttle with TProxy, please execute ``./cpe_sshuttle_tproxy_tcpandudp.sh``.

After these steps, you may perform an ``iperf`` experiment using ``iperf -s`` on the server and ``iperf -c 66.6.6.33`` on the client (add ``-u`` for UDP and ``-P 10`` for e.g. 10 parallel flows). If you want to measure latency, you may want to use [``tcpping``](https://github.com/deajan/tcpping).

**Launching scenario 1 with a SOCKS5 server (_ShadowSocks_) instead of OpenVPN**

In this case, for simplicity, no namespaces are employed. This scenario is available if you use the ``Vagrantfile.ALL`` file (please rename it to ``Vagrantfile``).

![image](https://user-images.githubusercontent.com/17797704/137905882-0702f2f6-9cc3-4dfc-89f3-17f777eb2768.png)

Steps to execute this scenario:

- **client**:
```
sudo route del default
sudo route add default gw 33.3.3.1
```

- **server**:
```
sudo route del default
sudo route add default gw 66.6.6.1
```

- **proxy1**:
```
sudo route del default
cd ~/free5gc/mptcp_test
sudo ip link set dev eth2 multipath off
./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_proxy1 -u 1
cd ~/vagrant/ShadowSocks
./proxy_shadowsocks.sh
```

- **CPE**:
```
sudo route del default
cd ~/free5gc/mptcp_test
./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_same_network_CPE -u 3
cd ~/vagrant/ShadowSocks
```

On the CPE, there are two alternatives. Using _ShadowSocks_ with _badvpn-tun2socks_ (both TCP and UDP) or with _ip2socks_ (only TCP but better performance). _badvpn-tun2socks_ creates a ``tun`` interface, whereas _ip2socks_ can select between a ``tun`` or a ``tap`` interface (please check the ``config-cpe-ip2socks.yml`` file). For _ShadowSocks_ with _badvpn-tun2socks_, please execute ``./cpe_shadowsocks_tun2socks_tun_tcpandudp.sh``. For _ShadowSocks_ with _ip2socks_, please execute ``./cpe_shadowsocks_ip2socks_onlytcp.sh``.

After these steps, you may perform an ``iperf`` experiment using ``iperf -s`` on the server and ``iperf -c 66.6.6.33`` on the client (add ``-u`` for UDP and ``-P 10`` for e.g. 10 parallel flows). If you want to measure latency, you may want to use [``tcpping``](https://github.com/deajan/tcpping).

## Launching SCENARIO 2: UE <-> free5GC <-> proxy

In this scenario, a VM (mptcpUe) employs three network interfaces (`eth1`, `eth2` and `eth4`) emulating a computer with three wireless access technologies (WATs), e.g. Wi-Fi, Li-Fi and 5G NR (directly connected to the _mptcpProxy_ VM since there is no gNB emulator to connect through UPF). We assume that they are in bridge mode, i.e. connected to the same IP network. This VM is directly connected to a VM (free5gc) implementing the 5G core network. The connection is done through the N3IWF (Non-3GPP InterWorking Function) entity. Since we are employing MPTCP to simultaneously transfer data from the three network interfaces of mptcpUe VM, it is required that the other end also implements MPTCP. Due to the different kernel versions on both VMs (~~4.19.1425.5~~5.4 for MPTCP and 5.0.0-23 for free5GC), another VM (mptcpProxy) is also required. mptcpProxy implements MPTCP for this purpose.

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

### TCP congestion window

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
- Install kernel ~~5.5~~5.4.144 with MPTCP support and reboot:
```
cd $HOME/vagrant
bash ./mptcp_kernel55_installation.sh
sudo reboot
```
- After rebooting, the NUC will have kernel ~~5.5~~5.4.144 (you should check it by executing `uname -r`) ~~but you will loose the driver for the Intel Gigabit Ethernet Controller I219-V. In order to install the driver (e1000e version 3.8.7) execute: (this was for kernel 5.4, which has some stabiltiy problems for the Wi-Fi card; it is not required with kernel 5.5)~~.
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

## Launching SCENARIO 2: UE <-> free5GC <-> proxy with NUC

In order to launch this scenario using a NUC, please follow these steps:

**PC working as mptcpProxy**:
- Check that the network interface that connects to the PC working as free5gc is configured with the correct IP address (60.60.0.101/24).
- Execute the following commands (assuming that `enp2s0` is the name of that network interface):
```
cd free5gc
sudo ./clarityMptcpProxy.sh -i 60.60.0.101/24 -I enp2s0 -g 60.60.0.102 -P fullmesh -S default -C olia
```

**PC working as free5gc**:
- Check that the network interface that connects to the NUC (working as mptcpUe) has the correct IP address (192.168.13.2/24).
- Check that the network interface that connects to the PC working as mptcpProxy has the correct IP address (60.60.0.102/24).
- Execute the following commands (assuming that `enx6038e0e3083f` is the name of the network interface that connects to the mptcpProxy):

```
cd go/src/free5gc
sudo ./clarity5gC.sh -n 2 -u -s 10.0.1 -i enx6038e0e3083f
```

**NUC**:
- We assume that the network interfaces are named `eno1` for the Ethernet card and `wlp0s20f3` for the WIFI6 card. Then, execute:

```
cd go/src/free5gc
sudo ./nuc.sh
```

** [TO BE FINISHED; explain here the nuc_connect_to_wifi.sh script..., and include the killing of the previous wpa_supplicant processes...]**

- After that, check that the network card is connected to the WIFI6 access point. For that purpose, execute:

`sudo ip netns exec UEns_2 iwconfig`

- If the NUC is correctly connected, run:

`sudo ./clarityUe_NUC.sh -n 2 -m -P fullmesh -S default -C olia -a -s 10.0.1 -o 60.60.0.101`

- You can check that everything works fine following the commands explained in scenario 2 (with `ping` and `iperf`, within the `MPTCPns` namespace).

**[Include here a picture with the results -> low datarate (~ 2 Mpbs) due to the low performance of free5gc]**

## Raspberry Pi 4 (64 bits) installation

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/rpi4.jpg" width="368">

Currently you can find kernel [rpi-5.5.y](https://github.com/raspberrypi/linux/tree/rpi-5.5.y) with MPTCP support in the ``vagrant/vagrant/MPTCP_kernel5.5_RPi`` directory. Tested with [Raspberry Pi OS (64 bits)](https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2020-08-24/2020-08-20-raspios-buster-arm64-lite.zip).

For this purpose, you should setup 2 Raspberry Pi 4. Currently it has been tested with two Ethernets (the one available in the Raspberry Pi, and one USB Ethernet adapter), `eth0` and `eth1`. Then follow these steps for each RPi4:

- Install [Raspberry Pi OS (64 bits)](https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2020-08-24/2020-08-20-raspios-buster-arm64-lite.zip). If you are using Windows on your PC, you could use e.g. [RUFUS](https://rufus.ie/) to save the image to the SD card.
- Boot and add your network configuration so the RPi4 has Internet connectivity.
- Copy the directory [MPTCP_kernel5.5_RPi4](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/tree/main/vagrant/vagrant/MPTCP_kernel5.5_RPi4) from this repo to `$HOME`. Enter the directory and execute `sudo ./mptcp_kernel_installation_rpi4.sh`. After a reboot, enter again the directory and execute `sudo ./mptcp_additional_installation_rpi4.sh`  to install `iperf`, `ifstat` and `iproute-mptcp`.
- Copy the directory `mptcp_test` from this repo to `$HOME`.
- Use if_names.txt.scenario1_different_networks_RPiX, X=1,2, so that the first network cards are `eth0` and `eth1` (you should check the name of the network cards using `ifconfig`).
- On the first RPi4, we will use IP addresses 1.1.1.1/24 and 1.1.2.1/24. Execute `./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_different_networks_RPi1 -u 2`.
- On the second RPi4, we will use IP addresses 1.1.1.2/24 and 1.1.2.2/24. Execute `./set_MPTCP_parameters.sh -p fullmesh -s roundrobin -c olia -f if_names.txt.scenario1_different_networks_RPi2 -u 2`.
- You can check that it works by executing on the first RPi4 `iperf -s & ifstat` and on the second RPi4 `iperf -c 1.1.1.1 & ifstat`.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/rpi_scenario1.jpeg" width="512">

**UPDATE**: An installable kernel 5.5 for Raspbian OS with MPTCP support and Weighted Round-Robin (WRR) v0.5 is available in the [MPTCP_kernel5.5-WRR0.5_RPi4](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/tree/main/vagrant/vagrant/MPTCP_kernel5.5_WRR05_RPi4) directory. **Tested with two network interfaces** (the one from RPi and one USB-Ethernet adapter). Follow these steps for testing WRR v0.5:

- Install the MPTCP kernel in the RPi4 by executing the script `mptcp_kernel_installation_rpi4.sh`. After reboot, check that it is installed by executing `uname -r`. Then execute the script `mptcp_additional_installation_rpi4.sh` to install the required packages. Repeat this for the second RPi.
- On the first RPi4, go to the `mptcp_test` directory and execute `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_different_networks_RPi1 -u 2 -m -o server` (we assume that the Ethernet interfaces are `eth0` (10.1.1.1/24) and `eth1` (10.1.2.1/24), update the file `if_names.txt.scenario1_different_networks_RPi1` if needed).
- On the second RPi4 (`eth0` with IP address 10.1.1.2/24 and `eth1` with IP address 10.1.2.2/24), go to the `mptcp_test` directory and execute `./set_MPTCP_parameters.sh -p fullmesh -s default -c olia -f if_names.txt.scenario1_different_networks_RPi2 -u 2 -m -o client -S 10.1.1.1`.
- To modify the weights, on the second RPi4 go to the [mptcp_ctrl](https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/tree/main/vagrant/vagrant/MPTCP_kernel5.5_WRR05_RPi4/mptcp_ctrl) directory and execute `sudo python3 wrr_simple_test2.py`. This will use weight=1 for `eth0` and weight=2 for `eth1`. Repeat for the first RPi4 if you want to test in the other direction (using `wrr_simple_test1.py`).
- Now you can test the proper behaviour using `iperf` within the `MPTCPns` namespace.

<img src="https://github.com/jorgenavarroortiz/5g-clarity_testbed_v0/raw/main/img/rpi4_wrr05_test.jpg" width="512">

**UPDATE**: An installable kernel 5.4 (LTS) for Ubuntu 20.04 (ARM64) with MPTCP support and Weighted Round-Robin (WRR) v0.5 is available in the [rpi-ubuntu-20.04-kernel5.4-mptcp-wrr](https://github.com/jorgenavarroortiz/multitechnology_testbed_v0/tree/main/vagrant/vagrant/rpi-ubuntu-20.04-kernel5.4-mptcp-wrr) directory. There you can find the instructions to install it. **Tested with two network interfaces** (the one from RPi and one USB-Ethernet adapter).
