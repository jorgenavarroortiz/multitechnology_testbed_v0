#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -f <filename>" 1>&2;
  echo " E.g.: $0 -f tcp_probe.log";
  echo "       <filename> .......... file where tcp_probe data are saved"
  exit 1;
}

while getopts ":f:" o; do
    case "${o}" in
        f)
            f=1
            FILENAME=${OPTARG}
            echo "FILENAME="$FILENAME
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${f}" ]; then
    usage
fi

sudo sh -c 'echo 0 > /sys/kernel/debug/tracing/events/tcp/tcp_probe/enable'
sudo cp /sys/kernel/debug/tracing/trace $FILENAME
