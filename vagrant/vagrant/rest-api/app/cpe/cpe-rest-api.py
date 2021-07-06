import sys
#sys.path.insert(1, '/home/mptcp/v06')   # jjramos, 2/7/2021
#import mptcp_wrr_controller as wrr

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

import json
import time
import itertools

tags_metadata = [
        {
            "name":"telemetry",
            "description": "endpoints for telemetry data"
            },
        {
            "name":"MPTCP",
            "description": "endpoints related to MPTCP"
            },
        ]

app = FastAPI(
        title="5G-CLARITY Testbed v1 Demo: OVS scenario",
        description="Documentation",
        version="0.1.1",
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


#######################
#
# jjramos 04/0/2021
#
print("Reading configuration file...")

config={}
namespace=None

with open("cpe.cfg") as json_file:
    config=json.load(json_file)

if "wrr_library_path" in config:
    sys.path.insert(1, config["wrr_library_path"])   # jjramos, 2/7/2021 '/home/mptcp/v06'
    import mptcp_wrr_controller as wrr

    print("WRR library path... "+config["wrr_library_path"])
if "sockets" in config:
    if "namespace" in config["sockets"]:
        namespace=config["sockets"]["namespace"]
        print("Sockets namespace... "+namespace)
#######################


# app.include_router(api_router)
class Services(BaseModel):
    services: List[dict]

    class Config:
        schema_extra = {
                "example": 
                    [{"redundant":{"enabled":True}},{"low-delay":{"enabled":False}},{"weighted-round-robin":{"enabled":True}}]
                }

class ServiceSockets(BaseModel):
    services: List[dict]

    class Config:
        schema_extra = {
                "example": 
                    [{"inode":12313}]
                }

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

@app.get("/cpe/services", tags=["services"], response_model=Services)
async def get_cpe_services():
    services_list=[{"redundant":{"enabled":True}},{"low-delay":{"enabled":True}},{"weighted-round-robin":{"enabled":True}}]

    return { "services":services_list}

@app.get("/cpe/services/{service}/sockets/{inode}/scheduler/mptcp/weights", tags=["MPTCP"])
async def cpe_scheduler_mptcp_get_rules(service,inode):
    
    try:
        status = wrr.get_local_interfaces_rules()

        print(status)

        return {'status':'success', 'rules': status}
    except ValueError as e:
        return {'status':'error'}

@app.post("/cpe/services/{service}/sockets/{inode}/scheduler/mptcp/weights", tags=["MPTCP"])
async def cpe_scheduler_mptcp_set_rules(service, inode, rules: Rules):    
    try:
        status = wrr.set_local_interfaces_rules(rules.rule)

        return {'status':'success', 'msg': f"The rule is {rules.rule}"}
    except ValueError as e:
        return {'status':'error', 'msg': f"The rule is {rules.rule}", 'error_msg': str(e)}


@app.get("/cpe/services/{service}/sockets/{inode}", tags=["services"])
async def get_cpe_service_socket_inode(service,inode):
    service_to_scheduler={"weighted-round-robin":"roundrobin","redundant":"redundant","low-delay":"default"}
    sched=service_to_scheduler[service]
    inode=int(inode)

    service_info=[]

    try:
        # Only for WRR:
        if service=="weighted-round-robin":
             
                scheduler=wrr.get_mptcp_socket_scheduler(inode,namespace)
                print("-> "+str(inode)+" "+sched)

                print(scheduler)

                if scheduler==sched:
                    mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode,namespace)
                    service_info.append({"inode":inode, "scheduler": sched, "subflows":mptcp_subflows})
        else:
            service_info.append({"inode":inode, "scheduler": sched})

        return {"status":"success", "socket_info":service_info}
    except:
        return {"status":"error"}

@app.get("/cpe/services/{service}/sockets", tags=["services"])
async def get_cpe_service_sockets(service):
    service_to_scheduler={"weighted-round-robin":"roundrobin","redundant":"redundant","low-delay":"default"}
    sched=service_to_scheduler[service]

    service_info=[]

    try:
        # Only for WRR:
        if service=="weighted-round-robin":
            mptcp_sockets=wrr.get_mptcp_sockets(namespace)

                # For each socket
            for mptcp_socket in mptcp_sockets:
                # We get the identifier of this socket (its inode)
                inode=mptcp_socket["inode"]

                scheduler=wrr.get_mptcp_socket_scheduler(inode,namespace)

                print(scheduler)

                if scheduler==sched:
                    mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode,namespace)
                    service_info.append({"inode":inode, "scheduler": sched, "subflows":mptcp_subflows})
        else:
            service_info.append({"inode":inode, "scheduler": sched})

        return {"status":"success", "sockets_info":service_info}
    except:
        return {"status":"error"}

@app.get("/cpe/telemetry/sockets", tags=["telemetry"])
async def get_cpe_telemetry_sockets():

    try:
        mptcp_sockets=wrr.get_mptcp_sockets(namespace)

        telemetries = []

        # For each socket
        for mptcp_socket in mptcp_sockets:
            # We get the identifier of this socket (its inode)
            inode=mptcp_socket["inode"]
            mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode,namespace)

            for subflow in mptcp_subflows:
                telemetries.append(wrr.get_mptcp_telemetry([subflow],namespace))

        telemetries = list(itertools.chain(*telemetries))

        return {"status":"success", "telemetry":telemetries}
    except:
        return {"status":"error"}

@app.get("/cpe/telemetry/sockets/{inode}", tags=["telemetry"])
async def get_cpe_telemetry_socket_inode(inode):
    try:
        inode=int(inode)
        mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode,namespace)
        
        telemetries = []
        for subflow in mptcp_subflows:
            telemetries.append(wrr.get_mptcp_telemetry([subflow],namespace))

        telemetries = list(itertools.chain(*telemetries))

        return {"status":"success", "telemetry":telemetries}
    except:
        return {"status":"error"}



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
        mptcp_sockets=wrr.get_mptcp_sockets(namespace)

        # For each socket
        for mptcp_socket in mptcp_sockets:
            # We get the identifier of this socket (its inode)
            inode=mptcp_socket["inode"]
            mptcp_subflows=wrr.get_mptcp_subflows_from_inode(inode,namespace)
        
        telemetries = []
        for subflow in mptcp_subflows:
            telemetries.append(wrr.get_mptcp_telemetry([subflow]))

        telemetries = list(itertools.chain(*telemetries))

        return {"status":"success", "telemetries":telemetries}
    except:
        return {"status":"error"}
