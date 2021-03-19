#!/bin/bash
#
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada

processid=`pgrep wpa_supplicant`

while [[ $processid != "" ]]; do
  echo "Killing wpa_supplicant process (${processid})..."
  sudo kill -9 $processid
  processid=`pgrep wpa_supplicant`
done

echo "Starting wpa_supplicant..."
sudo wpa_supplicant -Dnl80211 -i wlan0 -c ./wpa_supplicant.conf -B
