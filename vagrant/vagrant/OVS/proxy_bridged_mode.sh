#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

#sudo ifconfig mtap0 0 promisc up
sudo ifconfig eth2 0 promisc up
sudo brctl addbr toserver-br
sudo brctl addif toserver-br mtap0
sudo brctl addif toserver-br eth2
sudo ifconfig toserver-br up
