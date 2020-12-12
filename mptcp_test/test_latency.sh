#!/bin/bash
# Jorge Navarro, UGR (2020)

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -p <peer> [-f <filename>]" 1>&2;
  echo " E.g.: $0 -p 10.1.1.2";
  echo "       <peer> .............. IP address of the other device"
  echo "       <filename> .......... file to save trace (from stdout)"
  exit 1;
}

while getopts ":p:f:" o; do
    case "${o}" in
        p)
            p=1
            PEER=${OPTARG}
            echo "PEER="$PEER
            ;;
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

if [ -z "${p}" ]; then
    usage
fi

# Using mtr to test latency (using TCP)
if [[ $f == 1 ]]; then
   echo "Testing latency against ${PEER} but not saving results"
   sudo mtr -T -P 22 --no-dns -i 0.1 -c 100 $PEER -C
else
  echo "Testing latency against ${PEER} and saving results in file ${FILENAME}"
  sudo mtr -T -P 22 --no-dns -i 0.1 -c 100 $PEER -C | tee $FILENAME
fi
