import ipaddress
import socket
import os

def execute_sysctl_command(params):
    print("-> sysctl "+params)
    os.system('sysctl ' + params)

def ip_string_to_unsigned_int(ip):
    ip_ = 0
    bytes_ = ip.split(".")

    if len(bytes_) == 4:
        ip_ = socket.htonl((int(bytes_[0]) << 24) + (int(bytes_[1]) << 16) + (int(bytes_[2]) << 8) + int(bytes_[3]))
    return ip_

def generate_sysctl_params_string_apiv03(rules):
    sysctl_params = ""

    for rule in rules:
        src_ip="0"
        dst_ip="0"
        src_port="0"
        dst_port="0"
        weight="0"
        
        if "src_ip" in rule:
           src_ip=str(ip_string_to_unsigned_int(rule["src_ip"]))
        if "dst_ip" in rule:
           dst_ip=str(ip_string_to_unsigned_int(rule["dst_ip"]))
        if "src_port" in rule:
           src_port=str(rule["src_port"])
        if "dst_port" in rule:
           src_port=str(rule["dst_port"])
        if "weight" in rule:
           weight=str(rule["weight"])
        
        sysctl_params = sysctl_params+src_ip+" "+dst_ip+" "+weight+" "+src_port+" "+dst_port+" "

    sysctl_params = sysctl_params.strip()

    return sysctl_params

def generate_sysctl_params_string(ips_weights_dictionary):
    sysctl_params = ""

    for ip in ips_weights_dictionary:
        value=ips_weights_dictionary[ip]    	

        sysctl_params = sysctl_params + str(ip_string_to_unsigned_int(ip)) + " " + str(value) + " "

    sysctl_params = sysctl_params.strip()

    return sysctl_params

def generate_sysctl_port_params_string(ips_weights_dictionary):
    sysctl_params = ""

    for ip in ips_weights_dictionary:
        value=ips_weights_dictionary[ip]    	
    
        sysctl_params = sysctl_params + str(ip_string_to_unsigned_int(ip)) + " " + str(socket.htons(value)) + " "

    sysctl_params = sysctl_params.strip()

    return sysctl_params



def execute_sysctl_read_command(params):
    stream = os.popen("sysctl " + params)
    return stream.readline()

def set_local_interfaces_rules(rules):
    sysctl_params = generate_sysctl_params_string_apiv03(rules)
    execute_sysctl_command("-w net.mptcp.mptcp_wrr_li_weights=\"" + sysctl_params + "\"")

def set_local_interfaces_weights(ips_weights_dictionary):
    sysctl_params = generate_sysctl_params_string(ips_weights_dictionary)
    execute_sysctl_command("-w net.mptcp.mptcp_wrr_li_weights=\"" + sysctl_params + "\"")


def set_remote_interfaces_weights(ips_weights_dictionary):
    sysctl_params = generate_sysctl_params_string(ips_weights_dictionary)
    execute_sysctl_command("-w net.mptcp.mptcp_wrr_ri_weights=\"" + sysctl_params + "\"")

def set_remote_interfaces_ports(ips_ports_dictionary):
    sysctl_params = generate_sysctl_port_params_string(ips_ports_dictionary)
    execute_sysctl_command("-w net.mptcp.mptcp_wrr_ri_port=\"" + sysctl_params + "\"")

def set_local_interfaces_ports(ips_ports_dictionary):
    sysctl_params = generate_sysctl_port_params_string(ips_ports_dictionary)
    execute_sysctl_command("-w net.mptcp.mptcp_wrr_li_port=\"" + sysctl_params + "\"")

def get_remote_interfaces_weights():
    return get_sysctl_pair_ip_value("net.mptcp.mptcp_wrr_ri_weights", default_value=1)


def get_srtt_values():
    return get_sysctl_pair_ip_value("net.mptcp.mptcp_wrr_srtt", default_value=-1)


def get_cwnd_values():
    return get_sysctl_pair_ip_value("net.mptcp.mptcp_wrr_cwnd", default_value=-1)




def get_sysctl_pair_ip_value(sysctl_param, default_value=-1):
    values = []
    output = execute_sysctl_read_command(sysctl_param)
    # output="net.mptcp.mptcp_wrr_li_weights = 335544330      0       1       0       0       0       0    0"

    words = output.split("=")

    params = words[1].replace('\t', ' ')
    params = params.strip(" \t\n")
    params = params.split(' ')
    params = list(filter(''.__ne__, params))  # filters all "" occurrences (__ne__ => not equal)

    # print(params)
    # print(len(params))
    
    if len(params) < 2:
        values = []
    else:
        for i in range(0, len(params) - 1, 5):
            if params[i] != "0":
                value = default_value
                if i + 2 < len(params):
                    value = params[i + 2]

                ip = format(ipaddress.IPv4Address(int(params[i].strip())))
                values.append({"src_ip":ip, "weight":value})
            else:

                ip = format(ipaddress.IPv4Address(int(params[i].strip())))
                values.append({"src_ip":ip, "weight":0})


    return values
    
def get_local_interfaces_weights():
    # weights = {}
    # output = execute_sysctl_read_command("net.mptcp.mptcp_wrr_li_weights")
    # # output="net.mptcp.mptcp_wrr_li_weights = 335544330      1       0       0       0       0       0    0"
    #
    # words = output.split("=")
    #
    # params = words[1].replace('\t', ' ')
    # params = params.strip(" \t\n")
    # params = params.split(' ')
    # params = list(filter(''.__ne__, params))  # filters all "" occurrences (__ne__ => not equal)
    #
    # if len(params) < 2:
    #     weights = {}
    # else:
    #     for i in range(0, len(params) - 1, 2):
    #         if params[i] != "0":
    #             weight = 1
    #             if i + 1 < len(params):
    #                 weight = params[i + 1]
    #
    #             ip = format(ipaddress.IPv4Address(int(params[i].strip())))
    #             weights[ip] = weight
    #
    # return weights
    return get_sysctl_pair_ip_value("net.mptcp.mptcp_wrr_li_weights", default_value=1)
