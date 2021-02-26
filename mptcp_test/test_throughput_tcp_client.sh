#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), Univerity of Granada 2020

# Default values
DURATION=100

#############################
# Parsing inputs parameters
#############################

usage() { echo "Usage: $0 -s <server> [-d duration] [-f <filename>] [-h]" 1>&2; exit 1; }

while getopts ":s:d:f:h" opt; do
    case "${opt}" in
        s)
            s=1
            SERVER=${OPTARG}
            echo "SERVER=${SERVER}"
            ;;
        d)
            d=1
            DURATION=${OPTARG}
            echo "DURATION=${DURATION}"
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
