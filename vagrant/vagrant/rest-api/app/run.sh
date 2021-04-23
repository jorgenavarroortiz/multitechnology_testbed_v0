#!/bin/bash

#export env vars to be read by python files
export WIFI_IP=10.1.1.2
export LIFI_IP=10.1.2.2
export GNB_IP=10.1.3.2

# save default iptables
iptables-save > .iptables-default

# run uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000

# restore the iptables
iptables-restore < .iptables-default
