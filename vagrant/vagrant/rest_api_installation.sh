#!/bin/bash
# Ardimas Purwita

sudo apt-get -y update
sudo apt-get install -y speedometer

sudo apt-get install -y python3-pip
yes | pip3 install pipenv
sudo apt-get install -y python3.7
sudo apt install -y python3-distutils

cd $HOME/vagrant/rest-api/app
yes | sudo python3 -m pipenv --python 3.7
yes | sudo  python3 -m pipenv install -r requirements.txt
