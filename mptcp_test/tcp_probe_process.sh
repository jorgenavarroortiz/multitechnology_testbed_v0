#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -f <filename>" 1>&2;
  echo " E.g.: $0 -f tcp_probe.log ";
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

FILENAMEWOEXT=`echo "$FILENAME" | cut -d'.' -f1`

cat $FILENAME | grep mptcp | awk '{ for(i=1;i<=NF;i++) { if (substr($i, 0, 6) == "mptcp=") { print substr($i, 7); } } }' | awk '!seen[$0] {print} {++seen[$0]}' > .tmp_flows

while read line; do
  flow=$line
  echo "MPTCP flow being processed: ${flow}"
  grep tcp_probe $FILENAME | grep mptcp=$flow | awk '{ printf substr($4, 0, length($4)-1)" "substr($12, length("snd_cwnd=")+1)" "substr($13, length("ssthresh=")+1)" "substr($14, length("snd_wnd=")+1)" "substr($15, length("srtt=")+1)" "substr($16, length("rcv_wnd=")+1)" "; print ""}' > ${FILENAMEWOEXT}_processed_${flow}.txt
done < .tmp_flows

rm .tmp_flows
