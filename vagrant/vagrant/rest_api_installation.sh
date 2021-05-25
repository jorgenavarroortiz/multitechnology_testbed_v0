#!/bin/bash
# Ardimas Purwita

sudo apt-get install -y speedometer

sudo apt-get install -y python-pip
yes | pip install pipenv
sudo apt-get install -y python3.7
sudo apt install -y python3-distutils

cd $HOME/vagrant/rest-api/app
yes | sudo python -m pipenv --python 3.7
yes | sudo  python -m pipenv install -r requirements.txt

sudo python -m pipenv run uvicorn main:app --host 0.0.0.0 --port 8000 &
