#!/bin/bash
# Jorge Navarro (jorgenavarro@ugr.es), Univerity of Granada

sudo apt-get -y update
sudo apt-get -y install build-essential libncurses-dev bison flex

cp $HOME/vagrant/gtp5g_working_with_kernel5.0.0-23.tar.gz $HOME
cd $HOME
tar xvfz gtp5g_working_with_kernel5.0.0-23.tar.gz
mv gtp5g_working_with_kernel5.0.0-23 gtp5g

cd $HOME/vagrant/kernel5.0.0-23
sudo dpkg -i *.deb
