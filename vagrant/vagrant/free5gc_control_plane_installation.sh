#!/bin/bash

# Required packages for control plane
sudo apt-get -y install mongodb wget git

# SSH credentials for bitbucket repository
cp ~/vagrant/ssh_credentials/id_rsa ~/.ssh/id_rsa
cp ~/vagrant/ssh_credentials/id_rsa.pub ~/.ssh/id_rsa.pub
chmod 400 .ssh/id_rsa

# 5G-CLARITY repository for free5gc
  # Adding RSA fingerprints
echo "|1|kvSBT3KBmK9g6dlxeh9qznodCcM=|+YZGPElms7JaGRNZp8Y+vdjA7lc= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkBdyzVt0HJVJKAmWVxQVm35rtIz9z3bztdMoLh7rGX0bnuCKVLhUygNiMjFO7v7P9t1fmNoXF354e884WdFhdNh1jzPGFtywMJJdhBmwKJp0uRt3NE+SNnX9z4bB1F+A5CDc8L7YnCcHesF+k/EI28pTgZAdwY4Pbs11DR7WU61n2tQWDFhcsg0BHaC6SLQZAhFfjdzPoXZgChaREp7upIRVnUGhykCbRmRMcg4gg0qdQ99dfQlM21mGaSZvLCN2Dy9noSAgRZ7HYgL5wrlJDfYj08PTdgTqSu+bIF0udYAMy6Ux4RIDzMxuZx0Z2VXIWfyREFR3Db/shWZV23J4p" >> ~/.ssh/known_hosts
echo "|1|LLVmO4V7aoFrt/d+VXBaez9j9jg=|QfNM3AmF96wO3VjD6/k/39wFjxc= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkBdyzVt0HJVJKAmWVxQVm35rtIz9z3bztdMoLh7rGX0bnuCKVLhUygNiMjFO7v7P9t1fmNoXF354e884WdFhdNh1jzPGFtywMJJdhBmwKJp0uRt3NE+SNnX9z4bB1F+A5CDc8L7YnCcHesF+k/EI28pTgZAdwY4Pbs11DR7WU61n2tQWDFhcsg0BHaC6SLQZAhFfjdzPoXZgChaREp7upIRVnUGhykCbRmRMcg4gg0qdQ99dfQlM21mGaSZvLCN2Dy9noSAgRZ7HYgL5wrlJDfYj08PTdgTqSu+bIF0udYAMy6Ux4RIDzMxuZx0Z2VXIWfyREFR3Db/shWZV23J4p" >> ~/.ssh/known_hosts
  # Clone free5gc project
cd /home/vagrant/go/src
#git clone https://github.com/free5gc/free5gc.git
git clone -b ugr_v01 ssh://git@bitbucket.i2cat.net:7999/sdwn/free5gc.git
  # install dependent packages
cd /home/vagrant/go/src/free5gc
chmod +x ./install_env.sh
./install_env.sh

  # setup the environment for compiling
cd /home/vagrant/go/src/free5gc
tar -C /home/vagrant/go -zxvf free5gc_libs.tar.gz

  # compile network function services
cd /home/vagrant/go/src/free5gc
go build -o bin/amf -x src/amf/amf.go
go build -o bin/ausf -x src/ausf/ausf.go
go build -o bin/nrf -x src/nrf/nrf.go
go build -o bin/nssf -x src/nssf/nssf.go
go build -o bin/pcf -x src/pcf/pcf.go
go build -o bin/smf -x src/smf/smf.go
go build -o bin/udm -x src/udm/udm.go
go build -o bin/udr -x src/udr/udr.go
go build -o bin/n3iwf -x src/n3iwf/n3iwf.go
go build -o bin/amf -x src/amf/amf.go
