#!/bin/bash
# Using this script, the CPE will remove the additional delay that was added to one MPTCP path

usage() {
  echo "Usage: $0 [-p <path>]" 1>&2;
  echo " E.g.: $0 -p 1" 1>&2;
  exit 1;
}

while getopts ":p:" o; do
    case "${o}" in
        p)
            p=1
            MPTCPPATH=${OPTARG}
#            echo "PATH="$MPTCPPATH
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

# Remove previous rule
sudo ip net exec MPTCPns tc qdisc del dev v_mp_${MPTCPPATH} root

