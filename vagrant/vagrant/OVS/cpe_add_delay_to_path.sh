#!/bin/bash
# Using this script, the CPE will add some delay to one MPTCP path

usage() {
  echo "Usage: $0 [-p <path>] [-d <delay in ms>]" 1>&2;
  echo " E.g.: $0 -p 1 -d 20" 1>&2;
  exit 1;
}

while getopts ":p:d:" o; do
    case "${o}" in
        p)
            p=1
            MPTCPPATH=${OPTARG}
#            echo "PATH="$MPTCPPATH
            ;;
        d)
            d=1
            DELAY=${OPTARG}
#            echo "DELAY="$DELAY
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

if [ -z "${p}" ] || [ -z "${d}" ] ; then
    usage
fi


INTERFACE="v_mp_${MPTCPPATH}"
DELAYMS="${DELAY}ms"

# Remove previous rule
sudo ip net exec MPTCPns tc qdisc del dev ${INTERFACE} root >/dev/null 2>&1

# Add new rule
sudo ip net exec MPTCPns tc qdisc add dev ${INTERFACE} root netem delay ${DELAYMS}
