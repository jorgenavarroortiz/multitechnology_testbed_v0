#!/bin/bash
FILENAME=$1
SUBTITLE=$2
TYPE=$3

if [ $# -eq 3 ]; then
   echo > gnuplot.in
   echo "set data style linespoints" >> gnuplot.in
   echo "show timestamp" >> gnuplot.in

   if [ $TYPE -eq 1 ]; then
     echo "set title \"TCP congestion window (${SUBTITLE})\"" >> gnuplot.in
     echo "set xlabel \"time (seconds)\"" >> gnuplot.in
     echo "set ylabel \"segments\"" >> gnuplot.in
    echo "plot \"${FILENAME}\" using 1:2 title \"snd_cwnd\" noenhanced, \\" >> gnuplot.in
    echo "     \"${FILENAME}\" using 1:3 title \"snd_ssthresh\" noenhanced" >> gnuplot.in
   elif [ $TYPE -eq 2 ]; then
     echo "set title \"TCP congestion window ($SUBTITLE)\"" >> gnuplot.in
     echo "set xlabel \"time (seconds)\"" >> gnuplot.in
     echo "set ylabel \"microseconds\"" >> gnuplot.in
     echo "plot \"${FILENAME}\" using 1:5 title \"srtt\" noenhanced" >> gnuplot.in
   elif [ $TYPE -eq 3 ]; then
     echo "set title \"TCP congestion window (${SUBTITLE})\"" >> gnuplot.in
     echo "set xlabel \"time (seconds)\"" >> gnuplot.in
     echo "set ylabel \"segments\"" >> gnuplot.in
     echo "plot \"${FILENAME}\" using 1:4 title \"snd_wnd\" noenhanced, \\" >> gnuplot.in
     echo "     \"${FILENAME}\" using 1:6 title \"rcv_wnd\" noenhanced" >> gnuplot.in
   fi

   gnuplot -p < gnuplot.in 2> /dev/null
   rm gnuplot.in
else
   echo "";
   echo "Syntax: $0 <filename> <subtitle> <type>"
   echo "        type=1 for congestion window and slow start threshold"
   echo "        type=2 for smooth RTT"
   echo "        type=3 for advertised windows"
   echo ""
   exit 0
fi
