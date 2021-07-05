import requests
import re


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

URLS_GET = [
    'http://localhost:9888/telemetry/if_name',
    'http://localhost:9888/mptcp/scheduler',
    'http://localhost:9888/mptcp/metrics',
    'http://localhost:9888/ovs/show',
    'http://localhost:9888/ovs/bridge_info/vpn-br',
    'http://localhost:9888/flow/show/vpn-br',
    'http://localhost:9888/flow/del_all'
]

URLS_POST = [
    'http://localhost:9888/mptcp/set_rules',
    'http://localhost:9888/vlan/set_vlan',
    'http://localhost:9888/vlan/del_vlan',
    'http://localhost:9888/vlan/add_rule_access_port',
    'http://localhost:9888/vlan/remove_rule_access_port',
    'http://localhost:9888/flow/add_tuple_rule',
    'http://localhost:9888/flow/remove_tuple_rule',
    'http://localhost:9888/flow/configure_client',
    'http://localhost:9888/utils/add_delay_to_path',
    'http://localhost:9888/utils/remove_delay_to_path',
]

DATA_POST = [
    """
        {
        "rule": [
            {
            "src_ip": "10.1.1.1",
            "weight": 1
            },
            {
            "src_ip": "10.1.1.2",
            "weight": 1
            },
            {
            "src_ip": "10.1.1.3",
            "weight": 1
            }
        ]
        }
    """,
    """
        {
        "interface": "eth4",
        "vlanid": [
            100,
            200,
            300
        ]
        }
    """,
    """
        {
        "interface": "eth4",
        "vlanid": [
            100,
            200,
            300
        ]
        }
    """,
    """
        {
        "interface": "eth4",
        "vlanid": [
            100,
            200,
            300
        ]
        }
    """,
    """
        {
        "interface": "eth4",
        "vlanid": [
            100,
            200,
            300
        ]
        }
    """,
    """
        {
        "ip_source": "66.6.6.22",
        "ip_destination": "66.6.6.33",
        "proxy": 1
        }
    """,
    """
        {
        "ip_source": "66.6.6.22",
        "ip_destination": "66.6.6.33",
        "proxy": 1
        }
    """,
    """
        {
        "ip_source": "66.6.6.22",
        "ip_destination": "66.6.6.33",
        "proxy": 1
        }
    """,
    """
        {
        "path": 1,
        "delay": 20
        }
    """,
    """
        {
        "path": 1,
        "delay": 20
        }
    """
]

for URL in URLS_GET:
    response = requests.get(URL)
    success = True if response.status_code == 200 and response.json()['status'] == 'success' else False
    print(f"endpoint (GET): {URL.replace('http://localhost:9888','')}, status: {bcolors.OKGREEN if success else bcolors.FAIL}{'OK' if success else 'FAIL'} {bcolors.ENDC}")

for i,URL in enumerate(URLS_POST):
    response = requests.post(URL,data=DATA_POST[i])
    success = True if response.status_code == 200 and response.json()['status'] == 'success' else False
    print(f"endpoint (POST): {URL.replace('http://localhost:9888','')}, status: {bcolors.OKGREEN if success else bcolors.FAIL}{'OK' if success else 'FAIL'} {bcolors.ENDC}")

