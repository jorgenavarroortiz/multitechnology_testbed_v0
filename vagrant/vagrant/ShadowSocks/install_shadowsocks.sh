sudo apt-get -y install build-essential libtool
sudo apt-get -y install libpcre3 libpcre3-dev
sudo apt-get -y install asciidoc
sudo apt-get -y install libc-ares-dev
sudo apt-get -y install libev-dev

cd vagrant/ShadowSocks

tar xvfz shadowsocks-libev-nocrypto.tar.gz

cd shadowsocks-libev-nocrypto
pushd libsodium-1.0.18
make && make check
sudo make install
popd
sudo ldconfig

pushd mbedtls-2.6.0
make SHARED=1 CFLAGS="-O2 -fPIC"
sudo make DESTDIR=/usr install
popd
sudo ldconfig

./autogen.sh && ./configure && make
sudo make install
