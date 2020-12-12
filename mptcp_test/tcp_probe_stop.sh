#!/bin/bash
FILENAME=$1

sudo sh -c 'echo 0 > /sys/kernel/debug/tracing/events/tcp/tcp_probe/enable'
if [ $# -eq 1 ]; then
   sudo cp /sys/kernel/debug/tracing/trace $FILENAME
else
   echo "Syntax: $0 <filename>"
   exit 0
fi
