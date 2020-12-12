#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

sudo sh -c 'echo > /sys/kernel/debug/tracing/trace'
sudo sh -c 'echo 1 > /sys/kernel/debug/tracing/events/tcp/tcp_probe/enable'

# Trace is saved in file /sys/kernel/debug/tracing/trace
