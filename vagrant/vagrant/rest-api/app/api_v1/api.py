from fastapi import APIRouter

from api_v1.endpoints import telemetry, eat3s

api_router = APIRouter()
api_router.include_router(telemetry.router, prefix="/telemetry", tags=["Telemetry"])
api_router.include_router(eat3s.router, prefix="/eat3s", tags=["eAT3S"])

