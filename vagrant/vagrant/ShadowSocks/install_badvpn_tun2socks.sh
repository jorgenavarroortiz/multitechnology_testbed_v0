sudo apt-get -y install cmake

cd /home/vagrant/vagrant/ShadowSocks

tar xvfz badvpn.tar.gz

cd badvpn/build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1
make
sudo make install
