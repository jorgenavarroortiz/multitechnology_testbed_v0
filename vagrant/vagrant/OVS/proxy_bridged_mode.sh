#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

sudo ifconfig toserver-br down 2> /dev/null
sudo brctl delbr toserver-br 2> /dev/null

#sudo ifconfig mtap0 0 promisc up
sudo ifconfig eth2 0 promisc up
sudo brctl addbr toserver-br
sudo brctl addif toserver-br mtap0
sudo brctl addif toserver-br eth2
sudo ifconfig toserver-br up
