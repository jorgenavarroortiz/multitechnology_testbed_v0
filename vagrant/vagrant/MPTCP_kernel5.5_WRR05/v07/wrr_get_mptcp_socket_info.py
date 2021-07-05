#!/usr/bin/env python3
import time
import sys
import mptcp_wrr_controller as wrr

def main():
   
        inode=806620

        print("MPTCP socket inode "+str(inode))
        
        # We can get subflows assigned to a mptcp socket, by its inode:
        mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode)
        
        # We show the connection information of each subflow
        for mptcp_subflow in mptcp_subflows:
            print("\t"+mptcp_subflow["local_ip"]+":"+str(mptcp_subflow["local_port"])+" "+mptcp_subflow["remote_ip"]+":"+str(mptcp_subflow["remote_port"]))
            # print(mptcp_subflow)        

if __name__ == '__main__':
    main()
