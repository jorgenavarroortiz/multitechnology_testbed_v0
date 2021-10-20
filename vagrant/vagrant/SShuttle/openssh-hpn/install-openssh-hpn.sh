sudo service ssh stop

cd /home/vagrant/vagrant/SShuttle/openssh-hpn/dependencies
sudo dpkg -i *.deb

cd /home/vagrant/vagrant/SShuttle/openssh-hpn
sudo dpkg -i *.deb
sudo cp sshd_config /etc/ssh/

sudo service ssh restart
