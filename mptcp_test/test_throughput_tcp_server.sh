#!/bin/bash

#############################
# Parsing inputs parameters
#############################

usage() { echo "Usage: $0 [-f <filename>] [-h]" 1>&2; exit 1; }

while getopts ":f:h" opt; do
    case "${opt}" in
        f)
            f=1
            FILENAME=${OPTARG}
            echo "Trace saved to $FILENAME"
            ;;
        h)
            usage
            ;;
        *)
            ;;
    esac
done
shift $((OPTIND-1))

#if [ -z "${s}" ]; then
#    usage
#fi

if [[ $f == 1 ]]; then
   echo "Saving results in file ${FILENAME}"
   iperf -s | tee $FILENAME
else
   echo "Not saving results"
   iperf -s
fi
