#!/bin/bash

sudo modprobe openvswitch
sudo /usr/share/openvswitch/scripts/ovs-ctl start
#sudo ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
#                     --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
#                     --private-key=db:Open_vSwitch,SSL,private_key \
#                     --certificate=db:Open_vSwitch,SSL,certificate \
#                     --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
#                     --pidfile --detach
#sudo ovs-vsctl --no-wait init
#sudo ovs-vswitchd --pidfile --detach

sudo ovs-vsctl del-br cpe-br 2&>1
sudo ovs-vsctl del-br vpn-br 2&>1
