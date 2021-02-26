#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -d <directory> -i <interface1> -i <interface2> ..." 1>&2;
  echo " E.g.: $0 -d test -i eth1 -i eth2";
  echo "       <directory> ......... directory where pcap files are saved"
  echo "       <interfaceX> ........ network interface to be traced"
  exit 1;
}

i=0
while getopts ":d:i:" o; do
    case "${o}" in
        d)
            d=1
            DIRECTORY=${OPTARG}
            echo "DIRECTORY="$DIRECTORY
            ;;
        i)
            i=i+1
            INTERFACES+=("$OPTARG")
            echo "INTERFACE="$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${d}" ] || [ -z "${i}" ]; then
    usage
fi

echo "Saving results in directory ${DIRECTORY}"
mkdir ${DIRECTORY}
touch ${DIRECTORY}/capture.pcap
chmod o=rw ${DIRECTORY}/capture.pcap

INTERFACESSTR=""
for val in "${INTERFACES[@]}"; do
    INTERFACESSTR="${INTERFACESSTR} -i $val"
done

sudo tshark $INTERFACESSTR -w ${DIRECTORY}/capture.pcap
