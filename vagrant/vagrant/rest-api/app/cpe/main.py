import sys
sys.path.insert(1, '/home/vagrant/vagrant/MPTCP_kernel5.5_WRR05/mptcp_ctrl')
import mptcp_wrr_controller as wrr

from typing import Optional
from pydantic import BaseModel
from typing import List

from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware

# from api_v1.api import api_router

from fastapi.openapi.docs import (
    get_redoc_html,
    get_swagger_ui_html,
)
from fastapi.staticfiles import StaticFiles

import subprocess
import os
import re

import json
import time
import itertools

from collections import Iterable

tags_metadata = [
        {
            "name":"telemetry",
            "description": "endpoints for telemetry data"
            },
        {
            "name":"MPTCP",
            "description": "endpoints related to MPTCP"
            },
        {
            "name":"OVS",
            "description": "endpoints related to OVS"
            },
        ]

app = FastAPI(
        title="5G-CLARITY Testbed v1 Demo: OVS scenario",
        description="Documentation",
        version="0.1.0",
        docs_url=None,
        redoc_url=None,
        openapi_tags=tags_metadata
        )


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.mount("/static", StaticFiles(directory="static"), name="static")

# app.include_router(api_router)

class IfName(BaseModel):
    list_if: List[dict]

class Rules(BaseModel):
    rule: List[dict]
    
    class Config:
        schema_extra = {
                "example": {
                            "rule": [{"src_ip":"10.1.1.1", "weight":1},{"src_ip":"10.1.1.2", "weight":1},{"src_ip":"10.1.1.3", "weight":1}]
                    }
                }

@app.get("/docs", include_in_schema=False)
async def custom_swagger_ui_html():
    return get_swagger_ui_html(
        openapi_url=app.openapi_url,
        title=app.title,
        swagger_favicon_url="/static/favicon.ico",
    )

@app.get("/redoc", include_in_schema=False)
async def redoc_html():
    return get_redoc_html(
        openapi_url=app.openapi_url,
        title=app.title + " - ReDoc",
        redoc_favicon_url="/static/favicon.ico",
    )

@app.get("/", include_in_schema=False)
async def root():
    response = RedirectResponse(url='/docs')
    return response
    # return {"message": "go to /docs for the documentation"}

@app.get("/telemetry/if_name", tags=["telemetry"], response_model=IfName)
async def get_interface_name():

    # run ip -j link
    try:
        process  = subprocess.run(["ip",'-j',"address"],universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        list_json = json.loads(process.stdout)
    except:
        list_json = []

    list_ifname = []
    idx = 0
    for data in list_json:
        try:
            list_ifname.append({str(idx):{'if_name':data['ifname'],'ip_addr':data['addr_info'][0]['local']}})
            idx += 1
        except:
            pass

    return {"list_if":list_ifname}

@app.get("/mptcp/scheduler", tags=["MPTCP"])
async def get_scheduler():

    return {'scheduler':wrr.get_mptcp_current_scheduler().split('=')[1].strip()}

@app.post("/mptcp/set_rules", tags=["MPTCP"])
async def set_rules(rules: Rules):
    
    try:
        status = wrr.set_local_interfaces_rules(rules.rule)

        return {'status':'success', 'msg': f"The rule is {rules.rule}"}
    except ValueError as e:
        return {'status':'error', 'msg': f"The rule is {rules.rule}", 'error_msg': str(e)}

@app.get("/mptcp/metrics", tags=["MPTCP"])
async def get_metrics():
    
    try:
        mptcp_sockets=wrr.get_mptcp_sockets()

        # For each socket
        for mptcp_socket in mptcp_sockets:
            # We get the identifier of this socket (its inode)
            inode=mptcp_socket["inode"]
            mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode)
        
        telemetries = []
        for subflow in mptcp_subflows:
            telemetries.append(wrr.get_mptcp_telemetry([subflow]))

        telemetries = list(itertools.chain(*telemetries))

        return {"status":"success", "telemetries":telemetries}
    except:
        return {"status":"error"}


@app.get("/ovs/show", tags=["OVS"])
async def get_ovs_status():
    try:
        process  = subprocess.run("ovs-vsctl -f json show".split(" "),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # parsing
        list_text = process.stdout.split('\n')
        dict_text = {}
        prev_bridge_name = None;
        prev_port_name = None;
        status_insert_bridge = False;
        status_insert_port = False
        for i,txt in enumerate(list_text):
            if 'Bridge' in txt:
                bridge_name = re.split(r" +",txt)[-1]
                dict_text[bridge_name] = {}
                prev_bridge_name = bridge_name
                status_insert_bridge = True
                continue

            if 'Port' in txt:
                port_name = re.split(r" +",txt)[-1]
                dict_text[bridge_name][port_name] = {}
                prev_port_name = port_name
                status_insert_port = True
                continue
                
            tmp = re.match(r"^ *[a-zA-Z]",txt)
            if tmp is not None:
                if tmp.span()[-1]-1 == 12:
                    key = re.split(r" +",txt)[1].replace(":","")
                    value = "".join(re.split(r" +",txt)[2:])
                    dict_text[bridge_name][port_name][key] = value

        return {"status":"success", "message":dict_text}

    except Exception as e:
        return {"status":"error", "message": str(e)}

@app.get("/ovs/bridge_info/{bridge_name}", tags=["OVS"])
async def get_ovs_bridge_info(bridge_name: str):
    try:
        process  = subprocess.run(f"/home/vagrant/vagrant/OVS/ovs_show_of.sh -b {bridge_name}".split(" "),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        text = process.stdout
        list_text = text.split('\n')
        list_text.pop()

        # parsing

        prev_port_name = None;


        ## get the port names
        port_names = []
        tmp = re.findall(r".*\d\((.*)\)",text)
        if tmp:
            port_names.append(tmp)

        tmp = re.findall(r".*LOCAL\((.*)\)",text)
        if tmp:
            port_names.append(tmp)

        ## flatten
        port_names = list(itertools.chain(*port_names))

        ## initiate dict
        dict_text = {}

        tmp = re.findall(r".*n_tables:(\d+)",text)
        if tmp:
            dict_text['n_tables'] = tmp[0]

        tmp = re.findall(r".*n_buffers:(\d+)",text)
        if tmp:
            dict_text['n_buffers'] = tmp[0]

        tmp = re.findall(r".*capabilities: (.+)",text)
        if tmp:
            dict_text['capabilities'] = tmp[0]

        tmp = re.findall(r".*actions: (.+)",text)
        if tmp:
            dict_text['actions'] = tmp[0]

        for port_name in port_names:
            dict_text[port_name] = {}

        ## loop
        for i,txt in enumerate(list_text):

            port_name = [el for el in port_names if isinstance(el, Iterable) and (el in txt)]
            if port_name:
                port_name = port_name[0]
                tmp = re.findall(r".*addr:(.+)",txt)
                dict_text[port_name]["addr"] = tmp[0]
                prev_port_name = port_name
                continue

            tmp = re.match(r"^ *[a-zA-Z]",txt)
            if tmp is not None:
                if tmp.span()[-1]-1 == 5:
                    key = re.split(r" +",txt)[1].replace(":","")
                    value = "".join(re.split(r" +",txt)[2:])
                    dict_text[prev_port_name][key] = value

        return {"status":"success", "message":dict_text} 

    except Exception as e:
        return {"status":"error", "message": str(e)}
