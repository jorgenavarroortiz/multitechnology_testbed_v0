#!/usr/bin/env python3
import time
import sys
import mptcp_wrr_controller as wrr

def main():
    # Warning! It must be called from the same name space that the mptcp socket.
    # we get the list of open MPTCP sockets:
    mptcp_sockets=wrr.get_mptcp_sockets()

    # For each socket
    for mptcp_socket in mptcp_sockets:
        # We get the identifier of this socket (its inode)
        inode=mptcp_socket["inode"]

        print("MPTCP socket inode "+str(inode)+" ("+mptcp_socket["scheduler"]+")")
        # We can get subflows assigned to a mptcp socket, by its inode:
        mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode)
        
        # Now, we can get the telemetry for the flows specified in a list:
        telemetry=wrr.get_mptcp_telemetry(mptcp_subflows)
        
        # We can print the telemetry of these subflows:
        print("Telemetry collection:")
        for sample in telemetry:
            print(sample)

    # We can also get telemetry from some subflows:
    subflow=mptcp_subflows[0]
    telemetries=wrr.get_mptcp_telemetry([subflow])
    telemetry=telemetries[0]
    print()
    print("Telemetry for subflow "+subflow["local_ip"]+":"+str(subflow["local_port"])+"->"+subflow["remote_ip"]+":"+str(subflow["remote_port"])+":")
    print("- Collecting time: "+str(telemetry["timestamp"]))
    print("- Average Round Trip Time: "+str(telemetry["rtt"]))
    print("- Round Trip Time Variance: "+str(telemetry["rtt_var"]))
    print("- Minimum RTT: "+str(telemetry["minrtt"]))
    print("- Sent/retransmitted/Delivered bytes: "+str(telemetry["bytes_sent"])+"/"+str(telemetry["bytes_retrans"])+"/"+str(telemetry["bytes_acked"]))
    print("- Average sending bitrate: "+str(telemetry["send_rate"]))
    print("- Congestion Window: "+str(telemetry["cwnd"]))
    print("- Maximum segment size: "+str(telemetry["mss"]))
    
        

if __name__ == '__main__':
    main()
