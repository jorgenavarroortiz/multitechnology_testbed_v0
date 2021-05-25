from typing import Optional

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import List, Union

import json
import subprocess
import os

import api_v1.endpoints.mptcp_wrr_controller as wrr

router = APIRouter()

class Rules(BaseModel):
    rule: List[dict]

@router.post("/set_rules/")
async def set_rules(rules: Rules):
    
    wrr.set_local_interfaces_rules(rules.rule)    

    return {'status':'success', 'msg': f"The rule is {rules.rule}"}

