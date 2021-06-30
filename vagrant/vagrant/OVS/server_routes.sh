#!/bin/bash

sudo route del default
sudo route add -net 10.8.0.0/24 gw 66.6.6.1
sudo route add -net 10.9.0.0/24 gw 66.6.6.2
sudo route add -net 10.10.0.0/24 gw 66.6.6.3
