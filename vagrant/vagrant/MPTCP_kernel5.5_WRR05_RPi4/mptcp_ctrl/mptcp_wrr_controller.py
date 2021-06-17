#
# 27/05/2021
# 04/06/2021 jjramos telemetry
# 11/06/2021 jjramos added scheduler type
#
import ipaddress
import socket
import struct
import time
import os


def get_mptcp_telemetry(subflows):
    telemetry = []

    filter = []
    for subflow in subflows:
        filter.append("( src " + subflow["local_ip"] + ":" + str(subflow["local_port"]) + " and dst " + subflow[
            "remote_ip"] + ":" + str(subflow["remote_port"]) + " )")

    filters = " or ".join(filter)

    # print("> ss -nite \"" + filters+"\"")

    stream = os.popen("ss -nite \"" + filters + "\"")
    lines = stream.readlines()

    for i in range(1, len(lines), 2):
        sample = {}
        lines[i] = lines[i] + lines[i + 1]  # the -e parameter creates 2 lines.
        # print(lines[i].split())
        tuples = lines[i].split()

        sample["timestamp"]=time.time()
        #sample["src"] = tuples[3]  # src
        #sample["dst"] = tuples[4]  # dst

        j = 0
        while j < len(tuples):
            values_ = tuples[j].split(":")
            if len(values_) > 1:
                if j==3:
                    src_ip_=values_[0].split("%")
                    sample["src_ip"]=src_ip_[0]
                    sample["src_port"]=values_[1]
                elif j==4:
                    sample["dst_ip"]=values_[0]
                    sample["dst_port"]=values_[1]                        
                elif values_[0] == "rtt":
                    rtt_ = values_[1].split("/")
                    sample["rtt"] = float(rtt_[0])
                    sample["rtt_var"] = float(rtt_[1])
                else:
                    label = values_[0]
                    value = values_[1]
                    if values_[0] == "ino":
                        label = "inode"
                        value = int(values_[1])

                    sample[label] = value  # TODO change to int/float if needed
            else:
                if values_[0] == "send":
                    bps=int(tuples[j + 1][:-3])  # we want to remove the "bps" substring
                    sample[values_[0]] = bps
                    sample["send_"]=tuples[j + 1]
                    j = j + 1
                elif values_[0] == "cubic":
                    sample["con_alg"] = values_[0]
            j = j + 1
        telemetry.append(sample)

    return telemetry


def proc_net_address_to_host(address):
    address_long = int(address, 16)
    return socket.inet_ntoa(struct.pack("<I", address_long))


# TODO check little endian?
def proc_net_port_to_host(port):
    return int(port, 16)


def get_mptcp_subflows_from_inode(inode, _proc_tcp_path="/proc/net/tcp"):
    socket_list = []

    with open(_proc_tcp_path, "rt") as file:
        lines = file.readlines()

        i = 0
        # Let's parse the line:
        for line in lines:
            # First line is a header.
            if i > 0:
                values = line.split()
                # print(values)
                _inode = int(values[9])

                if _inode == inode:
                    address = values[1].split(":")
                    local_address = proc_net_address_to_host(address[0])
                    local_port = proc_net_port_to_host(address[1])

                    address = values[2].split(":")
                    remote_address = proc_net_address_to_host(address[0])
                    remote_port = proc_net_port_to_host(address[1])

                    socket_list.append(
                        {"local_ip": local_address, "local_port": local_port, "remote_ip": remote_address,
                         "remote_port": remote_port})
            i = i + 1

    return socket_list

def set_mptcp_scheduler(_scheduler="default",_path="net.mptcp.mptcp_scheduler"):
    return execute_sysctl_command("-w "+_path+"="+scheduler)
    

def get_mptcp_current_scheduler():
    return execute_sysctl_read_command("net.mptcp.mptcp_scheduler")

def get_mptcp_socket_scheduler(inode):
    scheduler=None
    
    socket=get_mptcp_socket(inode)
    if socket!=None:
        scheduler=socket["scheduler"]

    return scheduler

def get_mptcp_socket(inode):
    socket=None
    socket_list= get_mptcp_sockets()

    for socket_ in socket_list:
        if socket_["inode"]==inode:
            socket=socket_
    
    return socket



def get_mptcp_sockets(_proc_mptcp_path="/proc/net/mptcp_net/mptcp"):
    socket_list = []

    with open(_proc_mptcp_path, "rt") as file:
        lines = file.readlines()

        i = 0
        # Let's parse the line:
        for line in lines:
            # First line is a header.
            if i > 0:
                values = line.split()
                # print(values)

                address = values[4].split(":")
                local_address = proc_net_address_to_host(address[0])
                local_port = proc_net_port_to_host(address[1])

                address = values[5].split(":")
                remote_address = proc_net_address_to_host(address[0])
                remote_port = proc_net_port_to_host(address[1])

                socket_list.append({"inode": int(values[9]), "local_ip": local_address, "local_port": local_port,
                                    "remote_ip": remote_address, "remote_port": remote_port, "scheduler": values[10]})
            i = i + 1

    return socket_list


def execute_sysctl_command(params):
    # print("-> sysctl "+params)
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
        src_ip = "0"
        dst_ip = "0"
        src_port = "0"
        dst_port = "0"
        weight = "0"

        if "src_ip" in rule:
            src_ip = str(ip_string_to_unsigned_int(rule["src_ip"]))
        if "dst_ip" in rule:
            dst_ip = str(ip_string_to_unsigned_int(rule["dst_ip"]))
        if "src_port" in rule:
            src_port = str(socket.htons(rule["src_port"]))
        if "dst_port" in rule:
            src_port = str(socket.htons(rule["dst_port"]))
        if "weight" in rule:
            weight = str(rule["weight"])

        sysctl_params = sysctl_params + src_ip + " " + dst_ip + " " + weight + " " + src_port + " " + dst_port + " "

    sysctl_params = sysctl_params.strip()

    return sysctl_params


def generate_sysctl_params_string(ips_weights_dictionary):
    sysctl_params = ""

    for ip in ips_weights_dictionary:
        value = ips_weights_dictionary[ip]

        sysctl_params = sysctl_params + str(ip_string_to_unsigned_int(ip)) + " " + str(value) + " "

    sysctl_params = sysctl_params.strip()

    return sysctl_params


def generate_sysctl_port_params_string(ips_weights_dictionary):
    sysctl_params = ""

    for ip in ips_weights_dictionary:
        value = ips_weights_dictionary[ip]

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
    values = {}
    output = execute_sysctl_read_command(sysctl_param)
    # output="net.mptcp.mptcp_wrr_li_weights = 335544330      1       0       0       0       0       0    0"

    words = output.split("=")

    params = words[1].replace('\t', ' ')
    params = params.strip(" \t\n")
    params = params.split(' ')
    params = list(filter(''.__ne__, params))  # filters all "" occurrences (__ne__ => not equal)

    if len(params) < 2:
        values = {}
    else:
        for i in range(0, len(params) - 1, 2):
            if params[i] != "0":
                value = default_value
                if i + 1 < len(params):
                    value = params[i + 1]

                ip = format(ipaddress.IPv4Address(socket.ntohl(int(params[i].strip()))))
                values[ip] = int(value)

    return values


def get_local_interfaces_rules(sysctl_param="net.mptcp.mptcp_wrr_li_weights", default_value=-1):
    output = execute_sysctl_read_command(sysctl_param)
    # output="net.mptcp.mptcp_wrr_li_weights = 335544330      1       0       0       0       0       0    0"

    words = output.split("=")

    params = words[1].replace('\t', ' ')
    params = params.strip(" \t\n")
    params = params.split(' ')
    params = list(filter(''.__ne__, params))  # filters all "" occurrences (__ne__ => not equal)

    values = []

    if len(params) < 5:
        values_ = {}
    else:
        for i in range(0, len(params) - 1, 5):
            values_ = {}
            if params[i] != "0":
                value = default_value

                values_["src_ip"] = format(ipaddress.IPv4Address(socket.ntohl(int(params[i].strip()))))
                values_["dst_ip"] = format(ipaddress.IPv4Address(socket.ntohl(int(params[i + 1].strip()))))
                values_["weight"] = int(params[i + 2].strip())
                values_["src_port"] = socket.ntohs(int(params[i + 3].strip()))
                values_["dst_port"] = socket.ntohs(int(params[i + 4].strip()))

                values.append(values_)
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
