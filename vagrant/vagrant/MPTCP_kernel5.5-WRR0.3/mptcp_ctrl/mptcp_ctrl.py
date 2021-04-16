#!/usr/bin/env python3

import sys
import argparse
import psutil
import mptcp_wrr_controller as wrr

parser = argparse.ArgumentParser(description='Controls Weighted Round Robin scheduler for MPTCP')
parser.add_argument('command', choices=['get_saddr_weights', 'set_saddr_weights', 'get_srrt', 'get_cwnd'],
                    help='Command to execute.')
parser.add_argument('ip_weight_pair', nargs='*',
                    help='Pairs <IP> <weight>')

# Example of command line: sudo python3 mptcp_ctrl.py set_saddr_weights 10.0.0.1 2 10.0.0.20 3

def set_saddr_weights(ip_weight_pair):
    error = 0
    ips_simple_rules=[];

    for i in range(0, len(ip_weight_pair) - 1, 2):
        ips_weights_dictionary = {}

        weight = 1

        if i + 1 < len(ip_weight_pair):
            weight = ip_weight_pair[i + 1]
        
        ips_weights_dictionary={"src_ip":ip_weight_pair[i], "weight": weight}
        ips_simple_rules.append(ips_weights_dictionary);

    print(ips_weights_dictionary)
    #wrr.set_local_interfaces_weights(ips_weights_dictionary)
    wrr.set_local_interfaces_rules(ips_simple_rules)

    return error


def get_saddr_weights():
    return wrr.get_local_interfaces_weights()


def get_cwnd():
    return wrr.get_cwnd_values()


def get_srtt():
    return wrr.get_srtt_values()


def main():
    # params = ""
    #
    # for i in range(1, len(sys.argv), 2):
    #     weight = 1
    #
    #     if i + 1 < len(sys.argv):
    #         weight = sys.argv[i + 1]
    #
    #     # print(ip2ul("10.0.0.22"))
    #     params += str(ip2ul(sys.argv[i])) + " " + str(weight) + " "
    args = parser.parse_args()
    # print(args)

    if 'get_saddr_weights' in args.command:
        print(get_saddr_weights())
    elif 'set_saddr_weights' in args.command:
        set_saddr_weights(args.ip_weight_pair)
    elif 'get_srrt' in args.command:
        print(get_srtt())
    elif 'get_cwnd' in args.command:
        print(get_cwnd())


if __name__ == '__main__':
    main()
