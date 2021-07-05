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
        # We get the identifier of this sockets (its inode)
        inode=mptcp_socket["inode"]

        print("MPTCP socket inode "+str(inode)+" ("+mptcp_socket["scheduler"]+")")
        
        # We can get subflows assigned to a mptcp socket, by its inode:
        mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode)
        
        # We show the connection information of each subflow
        for mptcp_subflow in mptcp_subflows:
            print("\t"+mptcp_subflow["local_ip"]+":"+str(mptcp_subflow["local_port"])+" "+mptcp_subflow["remote_ip"]+":"+str(mptcp_subflow["remote_port"]))
            # print(mptcp_subflow)        

if __name__ == '__main__':
    main()
