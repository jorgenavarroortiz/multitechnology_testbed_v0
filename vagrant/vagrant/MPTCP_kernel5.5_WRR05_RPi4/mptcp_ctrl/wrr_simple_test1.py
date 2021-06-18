#!/usr/bin/env python3
import time
import mptcp_wrr_controller as wrr

#
# Example of dinamically assigning weights to flows
#

def main():
    # "rules" is a list of tuples which define the set of weights to assign.
    # Currently, weights can be only set from outside a namespace. These weights/rules apply to all network namespaces and MPTCP sockets.
    # When the sending turn of a subflow begins, the WRR scheduler first checks if all the non-null parameters specified in each tuple matches the subflow parameters.
    # The parameters that can be specified are: "src_ip", "dst_ip", "src_port", "dst_port", and the desired weight (number of segments to be sent for each round) for that subflow.
    # Any other packet which does not meet with the tuple definition is assigned a weight of 1.

    # In this case, we assign the double of segments per round to packets sent from IP=10.1.2.1
    rules = [{"src_ip":"10.1.1.1", "weight":1},{"src_ip":"10.1.2.1", "weight":2}]
    wrr.set_local_interfaces_rules(rules)
    print(wrr.get_local_interfaces_rules())
#    time.sleep(20)

if __name__ == '__main__':
    main()
