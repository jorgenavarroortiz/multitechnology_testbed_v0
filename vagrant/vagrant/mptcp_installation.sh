sudo apt-get -y install git wget

# Net-tools supporting MPTCP (e.g. netstat -m)
cd $HOME
git clone https://github.com/multipath-tcp/net-tools.git
cd net-tools
cp $HOME/vagrant/net-tools/config.h .
make
sudo make install

# MPTCPtrace
sudo apt-get -y install check libssl-dev libpcap-dev autoconf pkg-config
cd $HOME
git clone https://github.com/multipath-tcp/mptcptrace
cd mptcprace
./autogen.sh
./configure
make
sudo make install

# iproute-mptcp (required for command "ip link set dev <interface> multipath <off/on/backup>")
cd $HOME
git clone https://github.com/multipath-tcp/iproute-mptcp.git
cd iproute-mptcp
make
sudo make install

# Tools
cd $HOME
sudo apt-get -y install bridge-utils xplot.org gnuplot iperf ifstat wireless-tools
sudo bash -c 'DEBIAN_FRONTEND=noninteractive apt-get -y install tshark'
