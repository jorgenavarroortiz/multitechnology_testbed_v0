#!/usr/bin/env python3
import time
import mptcp_wrr_controller as wrr

# This example shows how to change the weights for outgoing traffic from interfaces with
# IPs 10.0.0.20 and 10.0.0.21

def main():
    rules = [{"src_ip":"10.0.0.20", "weight":1},{"src_ip":"10.0.0.21", "weight":1},{"src_ip":"10.0.0.22", "weight":1}]

    wrr.set_local_interfaces_rules(rules)
    time.sleep(20)

    rules = [{"src_ip":"10.0.0.20", "weight":2},{"src_ip":"10.0.0.21", "weight":1}, {"src_ip":"10.0.0.22", "weight":1}]
    wrr.set_local_interfaces_rules(rules)
    time.sleep(20)

    rules = [{"src_ip":"10.0.0.20","weight":1},{"src_ip":"10.0.0.21", "weight":2}, {"src_ip":"10.0.0.22", "weight":1}]
    wrr.set_local_interfaces_rules(rules)
    time.sleep(20)

    rules = [{"src_ip":"10.0.0.20", "weight":1},{"src_ip":"10.0.0.21", "weight":1}, {"src_ip":"10.0.0.22", "weight":2}]
    wrr.set_local_interfaces_rules(rules)
    time.sleep(20)

    rules = [{"src_ip":"10.0.0.20", "weight":1},{"src_ip":"10.0.0.21", "weight":1},{"src_ip":"10.0.0.22", "weight":1}]
    wrr.set_local_interfaces_rules(rules)


if __name__ == '__main__':
    main()
