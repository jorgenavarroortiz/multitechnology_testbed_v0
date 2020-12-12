#!/bin/bash

# Default values
DURATION=100

#############################
# Parsing inputs parameters
#############################

usage() { echo "Usage: $0 -s <server> [-f <filename>] [-h]" 1>&2; exit 1; }

while getopts ":s:f:h" opt; do
    case "${opt}" in
        s)
            s=1
            SERVER=${OPTARG}
            ;;
        d)
            d=1
            DURATION=${OPTARG}
            ;;
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

if [ -z "${s}" ]; then
    usage
fi

if [[ $f == 1 ]]; then
   echo "Saving results in file ${FILENAME}"
   iperf -c $SERVER -t $DURATION | tee $FILENAME
else
   echo "Not saving results"
   iperf -c $SERVER -t $DURATION
fi
