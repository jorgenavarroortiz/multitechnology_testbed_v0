#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -d <directory>" 1>&2;
  echo " E.g.: $0 -d test";
  echo "       <directory> ......... directory where pcap files are saved"
  exit 1;
}

while getopts ":d:" o; do
    case "${o}" in
        d)
            d=1
            DIRECTORY=${OPTARG}
            echo "DIRECTORY="$DIRECTORY
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${d}" ]; then
    usage
fi

echo "Processing results in directory ${DIRECTORY}"
cd ${DIRECTORY}
sudo mptcptrace -f capture.pcap -s -G 50 -F 3 -a -r 1
