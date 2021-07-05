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

            print()
            # print("Telemetry for subflow "+sample["local_ip"]+":"+str(sample["local_port"])+"->"+sample["remote_ip"]+":"+str(sample["remote_port"])+":")
            print("- Average Round Trip Time: "+str(sample["rtt"]))
            print("- Round Trip Time Variance: "+str(sample["rtt_var"]))
            print("- Minimum RTT: "+str(sample["minrtt"]))
            print("- Sent/retransmitted/Delivered bytes: "+str(sample["bytes_sent"])+"/"+str(sample["bytes_retrans"])+"/"+str(sample["bytes_acked"]))
            print("- Average sending bitrate: "+str(sample["send_rate"]))
            print("- Congestion Window: "+str(sample["cwnd"]))
            
        

if __name__ == '__main__':
    main()
