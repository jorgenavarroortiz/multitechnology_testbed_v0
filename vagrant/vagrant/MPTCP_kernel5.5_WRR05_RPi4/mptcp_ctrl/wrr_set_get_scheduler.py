#!/usr/bin/env python3
import mptcp_wrr_controller as wrr 

def main():
    # Let's get the MPTCP scheduler name for the MPTCP sockets that will be opened:
    print("Scheduler for next MPTCP sockets: "+wrr.get_mptcp_current_scheduler())

    # We can set the scheduler to use for the next MPTCP sockets.
    # Possible values: "default", "redundant", "roundrobin"
    # Warning! We must have root provileges to use this command (under the hood, this function uses "sysctl -w")
    wrr.set_mptcp_scheduler("roundrobin")
    print("Scheduler for next MPTCP sockets: "+wrr.get_mptcp_current_scheduler())


if __name__ == '__main__':
    main()