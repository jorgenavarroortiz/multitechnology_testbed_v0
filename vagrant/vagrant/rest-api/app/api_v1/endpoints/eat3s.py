from typing import Optional

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import List, Union

import json
import subprocess
import os

import iptc # I need this to get the JSON output from iptables

router = APIRouter()

class Probs(BaseModel):
    wifi_prob: float = Field(ge=0,le=1)
    lifi_prob: float = Field(ge=0,le=1)
    gnb_prob: float = Field(ge=0,le=1)


@router.get("/get_probs/",response_model=Probs)
async def get_probabilities():
    data = iptc.easy.dump_table(iptc.Table.FILTER)
    
    wifi_prob = 1-float(data['INPUT'][0]['statistic']['probability'])
    lifi_prob = 1-float(data['INPUT'][1]['statistic']['probability'])
    gnb_prob = 1-float(data['INPUT'][2]['statistic']['probability'])

    return {'wifi_prob': wifi_prob, 'lifi_prob': lifi_prob, 'gnb_prob':gnb_prob}

@router.post("/set_probs/")
async def set_probabilities(probs: Probs):
    

    process = subprocess.run("iptables -R OUTPUT 1 --source {} --match statistic --mode random --probability {} -j REJECT".format(str(os.getenv('WIFI_IP')),str(1-probs.wifi_prob)).split(' '),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if process.returncode != 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
    process = subprocess.run("iptables -R OUTPUT 2 --source {} --match statistic --mode random --probability {} -j REJECT".format(str(os.getenv('LIFI_IP')),str(1-probs.lifi_prob)).split(' '),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if process.returncode != 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
    process = subprocess.run("iptables -R OUTPUT 3 --source {} --match statistic --mode random --probability {} -j REJECT".format(str(os.getenv('GNB_IP')),str(1-probs.gnb_prob)).split(' '),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if process.returncode != 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
    process = subprocess.run("iptables -R INPUT 1 --source {} --match statistic --mode random --probability {} -j REJECT".format(str(os.getenv('WIFI_IP')),str(1-probs.wifi_prob)).split(' '),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if process.returncode != 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
    process = subprocess.run("iptables -R INPUT 2 --source {} --match statistic --mode random --probability {} -j REJECT".format(str(os.getenv('LIFI_IP')),str(1-probs.lifi_prob)).split(' '),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if process.returncode != 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
    process = subprocess.run("iptables -R INPUT 3 --source {} --match statistic --mode random --probability {} -j REJECT".format(str(os.getenv('GNB_IP')),str(1-probs.gnb_prob)).split(' '),universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if process.returncode != 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


    return {'status': 'success'}
