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

    # In this case, packets sent from IP=10.0.0.20, IP=10.0.0.21 and IP=10.0.0.22 will have the same weight (1)
    rules = [{"src_ip":"10.0.0.20", "weight":1},{"src_ip":"10.0.0.21", "weight":1},{"src_ip":"10.0.0.22", "weight":1}]
    # We set the weihhts with the following function:
    wrr.set_local_interfaces_rules(rules)

    print(wrr.get_local_interfaces_rules())
    # Let's wait for 20 seconds before reassigning the weights:
    time.sleep(20)

    # In this case, we assign the double of segments per round to packets sent from IP=10.0.0.20
    rules = [{"src_ip":"10.0.0.20", "weight":2},{"src_ip":"10.0.0.21", "weight":1},{"src_ip":"10.0.0.22", "weight":1}]
    wrr.set_local_interfaces_rules(rules)
    print(wrr.get_local_interfaces_rules())
    time.sleep(20)

    rules = [{"src_ip":"10.0.0.20", "weight":2},{"src_ip":"10.0.0.21", "weight":2},{"src_ip":"10.0.0.22", "weight":1}]
    wrr.set_local_interfaces_rules(rules)
    print(wrr.get_local_interfaces_rules())
    time.sleep(20)

    rules = [{"src_ip":"10.0.0.20", "weight":2},{"src_ip":"10.0.0.21", "weight":2},{"src_ip":"10.0.0.22", "weight":3}]
    wrr.set_local_interfaces_rules(rules)
    print(wrr.get_local_interfaces_rules())
    time.sleep(20)

    rules = [{"src_ip":"10.0.0.20", "weight":1},{"src_ip":"10.0.0.21", "weight":1},{"src_ip":"10.0.0.22", "weight":1}]    
    wrr.set_local_interfaces_rules(rules)
    print(wrr.get_local_interfaces_rules())
    time.sleep(20)

if __name__ == '__main__':
    main()
