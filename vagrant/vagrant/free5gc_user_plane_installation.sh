#!/bin/bash

# Required packages for user plane
sudo apt -y install git gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev bridge-utils
go get -u github.com/sirupsen/logrus

# Linux keernel module 5G GTP-U
# The latest version corrects some compilation problems with the latest kernels, so now it is not required to have separate versions.
#if [[ `uname -r` == "5.4.0-mptcp" ]]; then
#  sudo modprobe udp_tunnel
#  sudo cp gtp5g_kernel5.4/gtp5g.ko /lib/modules/`uname -r`/kernel/drivers/net
#  sudo depmod -a
#  sudo modprobe gtp5g
#  sudo echo "gtp5g" >> /etc/modules
#else
#  # For kernel 5.0.2 (or others)
#  cd $HOME
#  git clone https://github.com/PrinzOwO/gtp5g.git
#  cd gtp5g
#  make
#  sudo make install
#fi

# SSH credentials for bitbucket repository
#cp $HOME/vagrant/ssh_credentials/id_rsa $HOME/.ssh/id_rsa
#cp $HOME/vagrant/ssh_credentials/id_rsa.pub $HOME/.ssh/id_rsa.pub
#chmod 400 .ssh/id_rsa

# 5G-CLARITY repository for free5gc
# Adding RSA fingerprints
#echo "|1|kvSBT3KBmK9g6dlxeh9qznodCcM=|+YZGPElms7JaGRNZp8Y+vdjA7lc= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkBdyzVt0HJVJKAmWVxQVm35rtIz9z3bztdMoLh7rGX0bnuCKVLhUygNiMjFO7v7P9t1fmNoXF354e884WdFhdNh1jzPGFtywMJJdhBmwKJp0uRt3NE+SNnX9z4bB1F+A5CDc8L7YnCcHesF+k/EI28pTgZAdwY4Pbs11DR7WU61n2tQWDFhcsg0BHaC6SLQZAhFfjdzPoXZgChaREp7upIRVnUGhykCbRmRMcg4gg0qdQ99dfQlM21mGaSZvLCN2Dy9noSAgRZ7HYgL5wrlJDfYj08PTdgTqSu+bIF0udYAMy6Ux4RIDzMxuZx0Z2VXIWfyREFR3Db/shWZV23J4p" >> .ssh/known_hosts
#echo "|1|LLVmO4V7aoFrt/d+VXBaez9j9jg=|QfNM3AmF96wO3VjD6/k/39wFjxc= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkBdyzVt0HJVJKAmWVxQVm35rtIz9z3bztdMoLh7rGX0bnuCKVLhUygNiMjFO7v7P9t1fmNoXF354e884WdFhdNh1jzPGFtywMJJdhBmwKJp0uRt3NE+SNnX9z4bB1F+A5CDc8L7YnCcHesF+k/EI28pTgZAdwY4Pbs11DR7WU61n2tQWDFhcsg0BHaC6SLQZAhFfjdzPoXZgChaREp7upIRVnUGhykCbRmRMcg4gg0qdQ99dfQlM21mGaSZvLCN2Dy9noSAgRZ7HYgL5wrlJDfYj08PTdgTqSu+bIF0udYAMy6Ux4RIDzMxuZx0Z2VXIWfyREFR3Db/shWZV23J4p" >> .ssh/known_hosts
#echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> $HOME/.ssh/known_hosts
# Clone free5gc project
#cd $GOPATH/src
##git clone -b ugr_v01 ssh://git@bitbucket.i2cat.net:7999/sdwn/free5gc.git
##git clone https://github.com/free5gc/free5gc.git
#git clone git@github.com:jorgenavarroortiz/5g-clarity_testbed_v0.git
#mv 5g-clarity_testbed_v0 free5gc

# Build from sources
cd $GOPATH/src/free5gc/src/upf
mkdir build
cd build
cmake ..
make -j`nproc`
# UPF library test
sudo ./bin/testgtpv1
