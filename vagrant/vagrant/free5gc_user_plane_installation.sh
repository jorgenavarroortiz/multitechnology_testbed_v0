#!/bin/bash

# Required packages for user plane
sudo apt -y install git gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev
go get -u github.com/sirupsen/logrus

# Linux keernel module 5G GTP-U
cd $HOME
git clone https://github.com/PrinzOwO/gtp5g.git
cd gtp5g
make
sudo make install

# SSH credentials for bitbucket repository
cp /home/vagrant/vagrant/ssh_credentials/id_rsa /home/vagrant/.ssh/id_rsa
cp /home/vagrant/vagrant/ssh_credentials/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
chmod 400 .ssh/id_rsa

# 5G-CLARITY repository for free5gc
# Adding RSA fingerprints
echo "|1|kvSBT3KBmK9g6dlxeh9qznodCcM=|+YZGPElms7JaGRNZp8Y+vdjA7lc= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkBdyzVt0HJVJKAmWVxQVm35rtIz9z3bztdMoLh7rGX0bnuCKVLhUygNiMjFO7v7P9t1fmNoXF354e884WdFhdNh1jzPGFtywMJJdhBmwKJp0uRt3NE+SNnX9z4bB1F+A5CDc8L7YnCcHesF+k/EI28pTgZAdwY4Pbs11DR7WU61n2tQWDFhcsg0BHaC6SLQZAhFfjdzPoXZgChaREp7upIRVnUGhykCbRmRMcg4gg0qdQ99dfQlM21mGaSZvLCN2Dy9noSAgRZ7HYgL5wrlJDfYj08PTdgTqSu+bIF0udYAMy6Ux4RIDzMxuZx0Z2VXIWfyREFR3Db/shWZV23J4p" >> .ssh/known_hosts
echo "|1|LLVmO4V7aoFrt/d+VXBaez9j9jg=|QfNM3AmF96wO3VjD6/k/39wFjxc= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkBdyzVt0HJVJKAmWVxQVm35rtIz9z3bztdMoLh7rGX0bnuCKVLhUygNiMjFO7v7P9t1fmNoXF354e884WdFhdNh1jzPGFtywMJJdhBmwKJp0uRt3NE+SNnX9z4bB1F+A5CDc8L7YnCcHesF+k/EI28pTgZAdwY4Pbs11DR7WU61n2tQWDFhcsg0BHaC6SLQZAhFfjdzPoXZgChaREp7upIRVnUGhykCbRmRMcg4gg0qdQ99dfQlM21mGaSZvLCN2Dy9noSAgRZ7HYgL5wrlJDfYj08PTdgTqSu+bIF0udYAMy6Ux4RIDzMxuZx0Z2VXIWfyREFR3Db/shWZV23J4p" >> .ssh/known_hosts
# Clone free5gc project
cd $GOPATH/src
git clone -b ugr_v01 ssh://git@bitbucket.i2cat.net:7999/sdwn/free5gc.git
#git clone https://github.com/free5gc/free5gc.git

# Build from sources
cd $GOPATH/src/free5gc/src/upf
mkdir build
cd build
cmake ..
make -j`nproc`
# UPF library test
sudo ./bin/testgtpv1
