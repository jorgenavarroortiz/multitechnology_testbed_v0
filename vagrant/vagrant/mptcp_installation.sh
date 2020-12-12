sudo apt-get -y install git wget

# Net-tools supporting MPTCP (e.g. netstat -m)
cd /home/vagrant
git clone https://github.com/multipath-tcp/net-tools.git
cd net-tools
cp /home/vagrant/vagrant/net-tools/config.h .
make
sudo make install

# MPTCPtrace
sudo apt-get -y install check libssl-dev libpcap-dev
cd /home/vagrant
git clone https://github.com/multipath-tcp/mptcptrace
cd mptcprace
./autogen
./configure
make
sudo make install

# iproute-mptcp (required for command "ip link set dev <interface> multipath <off/on/backup>")
git clone https://github.com/multipath-tcp/iproute-mptcp.git
cd iproute-mptcp
make
sudo make install

# Tools
sudo apt-get -y install bridge-utils xplot.org gnuplot iperf ifstat wireless-tools
sudo bash -c 'DEBIAN_FRONTEND=noninteractive apt-get -y install tshark'
