#!/bin/bash
FILENAME=$1
MACHINE=`hostname`
OVPN=`pgrep openvpn`

#############################
# Parsing inputs parameters
#############################

S=0

usage() { echo "Usage: $0 [-s <server>] [-n <namespace>] [-f <filename>] [-h]" 1>&2; exit 1; }

while getopts ":s:n:f:h" opt; do
    case "${opt}" in
        s)
            S=1
            SERVER=${OPTARG}
            ;;
        n)
            NS=True
            NAMESPACE=${OPTARG}
            echo "Test in namespace $NAMESPACE"
            ;;
        f)
            FILE=1
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

#if [ -z "${t}" ] || [ -z "${n}" ]; then
#    usage
#fi

DURATION=100

if [[ $S == 0 ]]; then
  if [[ $MACHINE == "mptcpUe" ]]; then
    SERVER="60.60.0.101"
  elif [[ $MACHINE == "mptcpUe1" ]]; then
    SERVER="10.1.1.3"
  elif [[ $MACHINE == "mptcpUe2" ]]; then
    SERVER="10.1.1.1"
  fi
fi

if [[ $NS ]]; then
  EXEC_IPERF="sudo ip netns exec ${NAMESPACE} iperf"
  echo "Connecting to ${SERVER} during ${DURATION} seconds over namespace ${NAMESPACE}..."
else
  EXEC_IPERF="iperf"
  echo "Connecting to ${SERVER} during ${DURATION} seconds..."
fi

if [ $# -eq 1 ]; then
   echo "Saving results in file ${FILENAME}"
   $EXEC_IPERF -c $SERVER -t $DURATION | tee $FILENAME
else
   echo "Not saving results"
   $EXEC_IPERF -c $SERVER -t $DURATION
fi
