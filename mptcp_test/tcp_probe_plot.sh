#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 -f <filename> -t <type of plot> [-s <subtitle>] [-x <xmin>] [-X <xmax>] [-y <ymin>] [-Y <ymax>]" 1>&2;
  echo " E.g.: $0 -f test_tcp_probe_processed_0.log -t 1 -s \"test\"";
  echo "       <filename> .......... file where tcp_probe data are saved"
  echo "       <type of plot>....... 1 for congestion window and slow start threshold"
  echo "                             2 for smooth RTT"
  echo "                             3 for advertised windows"
  echo "       <subtitle> .......... e.g. experiment identifier"
  echo "       <xmin> and <xmax> ... both have to be included or they will be ignored"
  echo "       <ymin> and <ymax> ... both have to be included or they will be ignored"
  exit 1;
}

while getopts ":f:t:s:x:X:y:Y:" o; do
  case "${o}" in
    f)
      f=1
      FILENAME=${OPTARG}
      echo "FILENAME="$FILENAME
      ;;
    t)
      t=1
      TYPE=${OPTARG}
      echo "TYPE="$TYPE
      ;;
    s)
      s=1
      SUBTITLE=${OPTARG}
      echo "SUBTITLE="$SUBTITLE
      ;;
    x)
      x=1
      xmin=${OPTARG}
      echo "xmin="$xmin
      ;;
    X)
      X=1
      xmax=${OPTARG}
      echo "xmax="$xmax
      ;;
    y)
      y=1
      ymin=${OPTARG}
      echo "ymin="$ymin
      ;;
    Y)
      Y=1
      ymax=${OPTARG}
      echo "ymax="$ymax
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${f}" ] || [ -z "${t}" ]; then
  usage
fi

echo > gnuplot.in
echo "set data style linespoints" >> gnuplot.in
echo "show timestamp" >> gnuplot.in

if [ $TYPE -eq 1 ]; then
  if [[ $s == 1 ]]; then
    echo "set title \"TCP congestion window and slow start threshold (${SUBTITLE})\"" >> gnuplot.in
  else
    echo "set title \"TCP congestion window and slow start threshold\"" >> gnuplot.in
  fi
  echo "set xlabel \"time (seconds)\"" >> gnuplot.in
  echo "set ylabel \"segments\"" >> gnuplot.in
  if [[ ($x == 1) && ($X == 1) ]]; then echo "set xrange [${xmin}:${xmax}]" >> gnuplot.in; fi
  if [[ ($y == 1) && ($Y == 1) ]]; then echo "set yrange [${ymin}:${ymax}]" >> gnuplot.in; fi
  echo "plot \"${FILENAME}\" using 1:2 title \"snd_cwnd\" noenhanced, \\" >> gnuplot.in
  echo "     \"${FILENAME}\" using 1:3 title \"snd_ssthresh\" noenhanced" >> gnuplot.in
elif [ $TYPE -eq 2 ]; then
  if [[ $s == 1 ]]; then
    echo "set title \"Smooth RTT ($SUBTITLE)\"" >> gnuplot.in
  else
    echo "set title \"Smooth RTT\"" >> gnuplot.in
  fi
  echo "set xlabel \"time (seconds)\"" >> gnuplot.in
  echo "set ylabel \"microseconds\"" >> gnuplot.in
  if [[ ($x == 1) && ($X == 1) ]]; then echo "set xrange [${xmin}:${xmax}]" >> gnuplot.in; fi
  if [[ ($y == 1) && ($Y == 1) ]]; then echo "set yrange [${ymin}:${ymax}]" >> gnuplot.in; fi
  echo "plot \"${FILENAME}\" using 1:5 title \"srtt\" noenhanced" >> gnuplot.in
elif [ $TYPE -eq 3 ]; then
  if [[ $s == 1 ]]; then
    echo "set title \"Advertised windows (${SUBTITLE})\"" >> gnuplot.
  else
    echo "set title \"Advertised windows\"" >> gnuplot.
  fi
  echo "set xlabel \"time (seconds)\"" >> gnuplot.in
  echo "set ylabel \"segments\"" >> gnuplot.in
  if [[ ($x == 1) && ($X == 1) ]]; then echo "set xrange [${xmin}:${xmax}]" >> gnuplot.in; fi
  if [[ ($y == 1) && ($Y == 1) ]]; then echo "set yrange [${ymin}:${ymax}]" >> gnuplot.in; fi
  echo "plot \"${FILENAME}\" using 1:4 title \"snd_wnd\" noenhanced, \\" >> gnuplot.in
  echo "     \"${FILENAME}\" using 1:6 title \"rcv_wnd\" noenhanced" >> gnuplot.in
fi

gnuplot -p < gnuplot.in 2> /dev/null
#rm gnuplot.in
