from typing import Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api_v1.api import api_router

from fastapi.openapi.docs import (
    get_redoc_html,
    get_swagger_ui_html,
)
from fastapi.staticfiles import StaticFiles

import subprocess
import os


app = FastAPI(
        title="eAT3S UE API",
        description="Documentation for eAT3S UE API",
        version="0.1.0",
        docs_url=None,
        redoc_url=None
        )


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(api_router)

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

@app.on_event("startup")
async def startup_event():
    subprocess.run(f"iptables -A OUTPUT --source {os.getenv('WIFI_IP')} --match statistic --mode random --probability 0 -j REJECT".split(' '))    
    
    subprocess.run(f"iptables -A OUTPUT --source {os.getenv('LIFI_IP')} --match statistic --mode random --probability 0 -j REJECT".split(' '))    

    subprocess.run(f"iptables -A OUTPUT --source {os.getenv('GNB_IP')} --match statistic --mode random --probability 0 -j REJECT".split(' '))    
    
    subprocess.run(f"iptables -A INPUT --destination {os.getenv('WIFI_IP')} --match statistic --mode random --probability 0 -j REJECT".split(' '))

    subprocess.run(f"iptables -A INPUT --destination {os.getenv('LIFI_IP')} --match statistic --mode random --probability 0 -j REJECT".split(' '))

    subprocess.run(f"iptables -A INPUT --destination {os.getenv('GNB_IP')} --match statistic --mode random --probability 0 -j REJECT".split(' '))


@app.get("/")
async def root():
    return {"message": "go to /docs for the documentation"}
