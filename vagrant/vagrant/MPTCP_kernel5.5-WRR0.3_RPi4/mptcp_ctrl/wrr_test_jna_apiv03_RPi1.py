#!/usr/bin/env python3
import time
import mptcp_wrr_controller as wrr

# This example shows how to change the weights for outgoing traffic from interfaces with
# IPs 10.1.1.1 and 10.1.2.1

def main():
    rules = [{"src_ip":"10.1.1.1", "weight":3},{"src_ip":"10.1.2.1", "weight":1},{"src_ip":"10.1.3.1", "weight":1}]

    wrr.set_local_interfaces_rules(rules)


if __name__ == '__main__':
    main()
