from typing import Optional

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List

import json
import subprocess
import time

router = APIRouter()

class IfName(BaseModel):
    if_name: List[str]

class Telemetry(BaseModel):
    valid: str
    time: str
    mtu: str
    rx_bytes: str
    rx_packets: str
    rx_errors: str
    rx_dropped: str
    tx_bytes: str
    tx_packets: str
    tx_errors: str
    tx_dropped: str

@router.get("/if_name/", response_model=IfName)
async def get_interface_name():

    # run ip -j link
    try:
        process  = subprocess.run(["ip",'-j',"link"],universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        list_json = json.loads(process.stdout)
    except:
        list_json = []

    list_ifname = [] 
    for data in list_json:
        list_ifname.append(data['ifname'])

    return {"if_name":list_ifname}


@router.get("/data/{if_name}", response_model=Telemetry)
async def get_telemetry_data(if_name: str):
    
    output = {
            "valid": "false",
            "time": str(time.time()),
            "mtu": str(0),
            "rx_bytes": str(0),
            "rx_packets": str(0),
            "rx_errors": str(0),
            "rx_dropped": str(0),
            "tx_bytes": str(0),
            "tx_packets": str(0),
            "tx_errors": str(0),
            "tx_dropped": str(0)
            }


    if if_name:
        current_time = time.time()
        process = subprocess.run("ip -j -s link show {}".format(if_name).split(' '),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            
        print(process.returncode)
        if process.returncode == 0:
            list_json = json.loads(process.stdout)

            data = list_json[0]
            output['valid']='true'
            output['time']= str(current_time)
            output['mtu']=data['mtu']
            output['rx_bytes']=data['stats64']['rx']['bytes']
            output['rx_packets']=data['stats64']['rx']['packets']
            output['rx_errors']=data['stats64']['rx']['errors']
            output['rx_dropped']=data['stats64']['rx']['dropped']
            output['tx_bytes']=data['stats64']['tx']['bytes']
            output['tx_packets']=data['stats64']['tx']['packets']
            output['tx_errors']=data['stats64']['tx']['errors']
            output['tx_dropped']=data['stats64']['tx']['dropped']
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"{if_name} not found")



    return output

