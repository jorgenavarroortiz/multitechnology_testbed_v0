# SS exporter for Prometheus (i.e. RTT, CWND, ... TCP flow parameters)
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada, 2021

# See https://sysdig.com/blog/prometheus-metrics/

# Example of output from ss -i -t:
#State               Recv-Q               Send-Q                              Local Address:Port                              Peer Address:Port
#ESTAB               0                   0                                     10.0.2.15:ssh                                  10.0.2.2:48234
#       olia rto:204 rtt:0.342/0.082 ato:40 mss:1460 pmtu:1500 rcvmss:536 advmss:1460 cwnd:10 bytes_acked:15121 bytes_received:2512 segs_out:43 segs_in:63 data_segs_out:34 data_segs_in:28 send 341.5Mbps lastsnd:13508 lastrcv:13512 lastack:13508 pacing_rate 681.5Mbps delivery_rate 192.1Mbps app_limited busy:36ms rcv_space:14600 rcv_ssthresh:64076 minrtt:0.106

import prometheus_client as prom
import random
import time
import os

DEBUG=False

if __name__ == '__main__':

   tcp_info_rtt_gauge = prom.Gauge('tcp_info_rtt_gauge', 'TCP mean RTT', ['source', 'destination'])
   tcp_info_rttstddev_gauge = prom.Gauge('tcp_info_rttstddev_gauge', 'TCP standard deviation of RTT', ['source', 'destination'])
   tcp_info_minrtt_gauge = prom.Gauge('tcp_info_minrtt_gauge', 'TCP minimum RTT', ['source', 'destination'])
   tcp_info_cwnd_gauge = prom.Gauge('tcp_info_cwnd_gauge', 'TCP congestion window', ['source', 'destination'])
   tcp_info_segs_in_gauge = prom.Gauge('tcp_info_segs_in_gauge', 'TCP segments in', ['source', 'destination'])
   tcp_info_segs_out_gauge = prom.Gauge('tcp_info_segs_out_gauge', 'TCP segments out', ['source', 'destination'])
   tcp_info_data_segs_in_gauge = prom.Gauge('tcp_info_data_segs_in_gauge', 'TCP data segments in', ['source', 'destination'])
   tcp_info_data_segs_out_gauge = prom.Gauge('tcp_info_data_segs_out_gauge', 'TCP data segments out', ['source', 'destination'])
   tcp_info_bytes_acked_gauge = prom.Gauge('tcp_info_bytes_acked_gauge', 'TCP bytes acknowledged', ['source', 'destination'])
   tcp_info_bytes_received_gauge = prom.Gauge('tcp_info_bytes_received_gauge', 'TCP bytes received', ['source', 'destination'])
   tcp_info_pacing_rate_gauge = prom.Gauge('tcp_info_pacing_rate_gauge', 'TCP pacing rate', ['source', 'destination'])
   tcp_info_delivery_rate_gauge = prom.Gauge('tcp_info_delivery_rate_gauge', 'TCP delivery rate', ['source', 'destination'])

   prom.start_http_server(8080)

# Go to sleep until Ctrl+C!
try:
   # *** ADD THIS PERIOD AS COMMAND LINE PARAMETER ***
   wait_time = 1.0
   while True:
     # Execute "ss -i -t" and save results

#     stream = os.popen('ss -i -t')
     stream = os.popen('sudo ip netns exec MPTCPns ss -i -t')
     output = stream.read()
     # Parse output from "ss -i -t"
     i = 0
     previousFirstWord = ""
     for line in output.splitlines():
       i = i + 1
       if DEBUG: print("Line " + str(i) + ": " + line)
       words = line.split()
       if DEBUG: print("No. words: " + str(len(words)))

       # Check if previous line was the header (field titles) of an established flow
       # If so, check each word to save stats for Prometheus
       if previousFirstWord == "ESTAB":
         for j in range(len(words)):
            if DEBUG: print("word[" + str(j) + "]: " + words[j])
            splittedWord = words[j].split(":")
            if len(splittedWord) >= 2:
               if DEBUG: print("splittedWord[0]: " + splittedWord[0])
               if DEBUG: print("splittedWord[1]: " + splittedWord[1])
               # Save results for Prometheus
               if splittedWord[0] == "rtt":
                 tmpSplittedWord = splittedWord[1].split("/")
                 if DEBUG: print("tmpSplittedWord[0]: " + tmpSplittedWord[0]) # Mean
                 if DEBUG: print("tmpSplittedWord[1]: " + tmpSplittedWord[1]) # Standard deviation
                 tcp_info_rtt_gauge.labels(sourceStr, destinationStr).set(tmpSplittedWord[0])
                 tcp_info_rttstddev_gauge.labels(sourceStr, destinationStr).set(tmpSplittedWord[1])
               elif splittedWord[0] == "minrtt":
                 tcp_info_minrtt_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "cwnd":
                 tcp_info_cwnd_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "segs_in":
                 tcp_info_segs_in_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "segs_out":
                 tcp_info_segs_out_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "data_segs_in":
                 tcp_info_segs_in_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "data_segs_out":
                 tcp_info_segs_out_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "bytes_acked":
                 tcp_info_bytes_acked_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "bytes_received":
                 tcp_info_bytes_received_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "pacing_rate":
                 tcp_info_pacing_rate_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])
               elif splittedWord[0] == "delivery_rate":
                 tcp_info_delivery_rate_gauge.labels(sourceStr, destinationStr).set(splittedWord[1])

       if len(words)>=5:
         if words[0] == "ESTAB":
            previousFirstWord = words[0]
            sourceStr = words[3]
            destinationStr = words[4]
       else:
         previousFirstWord = ""

     time.sleep(wait_time)

except KeyboardInterrupt:
   pass
