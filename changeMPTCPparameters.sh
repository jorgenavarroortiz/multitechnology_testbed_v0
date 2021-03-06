#!/usr/bin/env bash
#
# This script is used to modify the MPTCP parameters
#
# Author: Jorge Navarro-Ortiz (jorgenavarro@ugr.es)
# Copyright: University of Granada

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 [-P <path manager>] [-S <scheduler>] [-C <congestion control>] [-c <CWND limited>] [-h]" 1>&2;
  echo ""
  echo "Example: $0 -P fullmesh -S default -C olia"
  echo ""
  echo "       <path manager> ........... default, fullmesh, ndiffports, binder"
  echo "       <scheduler> .............. default, roundrobin, redundant"
  echo "       <congestion control> ..... reno, cubic, lia, olia, wvegas, balia, mctcpdesync"
  echo "       <CWND limited> ........... for roundrobin, whether the scheduler tries to fill the congestion window on all subflows (Y) or whether it prefers to leave open space in the congestion window (N) to achieve real round-robin (even if the subflows have very different capacities)"
  echo ""
  echo "       -h ....................... this help"
  exit 1;
}

# Default values
PATHMANAGER="fullmesh"
SCHEDULER="default"
CONGESTIONCONTROL="olia"
CWNDLIMITED="Y"

while getopts ":P:S:C:c:h" o; do
  case "${o}" in
    P)
      P=1
      PATHMANAGER=${OPTARG}
      echo "PATHMANAGER="$PATHMANAGER
      ;;
    S)
      S=1
      SCHEDULER=${OPTARG}
      echo "SCHEDULER="$SCHEDULER
      ;;
    C)
      C=1
      CONGESTIONCONTROL=${OPTARG}
      echo "CONGESTIONCONTROL="${OPTARG}
      ;;
    c)
      c=1
      CWNDLIMITED=${OPTARG}
      echo "CWNDLIMITED="${OPTARG}
      ;;
    h)
      h=1
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [[ $h == 1 ]]; then
  usage
fi

# Check if it is executed as root (exit otherwise)
if [[ `id -u` != 0 ]]; then
  echo "Please execute this script as root!"
  exit 1
fi

# Modify tunable variables
sysctl -w net.mptcp.mptcp_enabled=1     # Default 1
sysctl -w net.mptcp.mptcp_checksum=1    # Default 1 (both sides have to be 0 in order to disable this)
sysctl -w net.mptcp.mptcp_syn_retries=3 # Specifies how often we retransmit a SYN with the MP_CAPABLE-option. Default 3
sysctl -w net.mptcp.mptcp_path_manager=$PATHMANAGER
sysctl -w net.mptcp.mptcp_scheduler=$SCHEDULER

# Congestion control
sysctl -w net.ipv4.tcp_congestion_control=$CONGESTIONCONTROL

# CWND limited (only used if the scheduler is roundrobin)
echo $CWNDLIMITED | tee /sys/module/mptcp_rr/parameters/cwnd_limited
