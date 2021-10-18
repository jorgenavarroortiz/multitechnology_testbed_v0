#!/bin/bash

DEBUG=0
NOCIPHER=1

#sudo sysctl -w net.ipv4.ip_forward=1 # NOT REQUIRED FOR SSHUTTLE

# Default route
sudo route del default
sudo route add default gw 10.1.1.4

#if [ "$EUID" -ne 0 ]; then
#    echo "This script must be run as root. Exiting."
#    exit
#fi

# Since ipv6 can leak even with the --disable-ipv6 command...
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

if [[ $NOCIPHER -eq 1 ]]; then
   if [[ $DEBUG -eq 1 ]]; then
      sudo sshpass -p vagrant sshuttle --method=nat --disable-ipv6 -r vagrant@10.1.1.4 66.6.6.0/24 -x 10.0.2.0/24 -x 10.1.1.1 -x 10.1.1.2 -x 10.1.1.3 -l 0.0.0.0:0 -e 'sudo ssh -q -o NoneEnabled=yes -o NoneSwitch=yes -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --pidfile=/home/vagrant/sshuttle.pid -vvvv
   else
      sudo sshpass -p vagrant sshuttle --method=nat --disable-ipv6 -r vagrant@10.1.1.4 66.6.6.0/24 -x 10.0.2.0/24 -x 10.1.1.1 -x 10.1.1.2 -x 10.1.1.3 -l 0.0.0.0:0 -e 'sudo ssh -q -o NoneEnabled=yes -o NoneSwitch=yes -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --pidfile=/home/vagrant/sshuttle.pid
   fi
else
   if [[ $DEBUG -eq 1 ]]; then
      sudo sshpass -p vagrant sshuttle --method=nat --disable-ipv6 -r vagrant@10.1.1.4 66.6.6.0/24 -x 10.0.2.0/24 -x 10.1.1.1 -x 10.1.1.2 -x 10.1.1.3 -l 0.0.0.0:0 -e 'sudo ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --pidfile=/home/vagrant/sshuttle.pid -vvvv
   else
      sudo sshpass -p vagrant sshuttle --method=nat --disable-ipv6 -r vagrant@10.1.1.4 66.6.6.0/24 -x 10.0.2.0/24 -x 10.1.1.1 -x 10.1.1.2 -x 10.1.1.3 -l 0.0.0.0:0 -e 'sudo ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --pidfile=/home/vagrant/sshuttle.pid
   fi
fi
