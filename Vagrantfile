# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
#Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "bento/ubuntu-18.04"

  config.ssh.username = 'vagrant'
  config.ssh.password = 'vagrant'
  config.ssh.insert_key = false

  # Custom: SSH graphical, X11
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true  

  # avoid mounting shared folder
  config.vm.synced_folder '.', '/vagrant', disabled: true

  ####################
  # Defining the free5gC core VM
  ####################
  config.vm.define "free5gc" do |a|
	a.vm.network "private_network", ip: "192.168.13.2", auto_config: true # Net connecting to MPTCP UE
	a.vm.network "private_network", ip: "192.168.20.2", auto_config: true # Net connecting to MPTCP Proxy    	
    a.vm.hostname = "free5gc"	
    a.vm.provider :virtualbox do |vm|    	
    	# Configure networking interfaces
		vm.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
		vm.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
		# Config name that appears in virtual box
    	vm.name = "free5gc"
    	# DNS queries to the host, which becomes a DNS Proxy
		vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		# Lease more RAM to the guest
		vm.customize ["modifyvm", :id, "--memory", "4096"]
    	# Set number of CPUs
    	vm.customize ["modifyvm", :id, "--cpus", 2]
	end
  end

  ####################
  # Defining the MPTCP UE VM
  ####################
  config.vm.define "mptpcUe" do |mptpcUe|
	mptpcUe.vm.network "private_network", ip: "192.168.13.3", auto_config: true # Interface 1 connecting to free5gC core
	mptpcUe.vm.network "private_network", ip: "192.168.13.4", auto_config: true # Interface 2 connecting to free5gC core
	mptpcUe.vm.hostname = "mptpcUe"
    mptpcUe.vm.provider :virtualbox do |vm|
    	# Configure networking interfaces
		vm.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
		vm.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
		# Config name that appears in virtual box
    	vm.name = "mptpcUe"
    	# DNS queries to the host, which becomes a DNS Proxy
		vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		# Lease more RAM to the guest
		vm.customize ["modifyvm", :id, "--memory", "4096"]
    	# Set number of CPUs
    	vm.customize ["modifyvm", :id, "--cpus", 2]		
	end
  end

  ####################
  # Defining the MPTCP proxy
  ####################
  config.vm.define "mptcpProxy" do |mptcpProxy|
	mptcpProxy.vm.network "private_network", ip: "192.168.20.3", auto_config: true # Net connecting to free5gc core
	mptcpProxy.vm.hostname = "mptcpProxy"
    mptcpProxy.vm.provider :virtualbox do |vm|
    	# Configure networking interfaces
		vm.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
		# Config name that appears in virtual box
    	vm.name = "mptcpProxy"
    	# DNS queries to the host, which becomes a DNS Proxy
		vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		# Lease more RAM to the guest
		vm.customize ["modifyvm", :id, "--memory", "4096"]
    	# Set number of CPUs
    	vm.customize ["modifyvm", :id, "--cpus", 2]
	end
  end

end
