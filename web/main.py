#! /usr/bin/env python3
import logging
import shutil
import subprocess
import time
from enum import Enum
from pathlib import Path
from typing import Any

import appdirs
from pydantic import BaseModel
import uvicorn
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import HTMLResponse
from fastapi_versioning import VersionedFastAPI, version
from fastapi.staticfiles import StaticFiles
from loguru import logger

SERVICE_NAME = "zerotiermanager"

# logging.basicConfig(handlers=[InterceptHandler()], level=0)
#logger.add(get_new_log_path(SERVICE_NAME))

class Settings(BaseModel):
    settings: str

app = FastAPI(
    title="ZeroTierManager API",
    description="ZeroTierManager is an extension to provide ZeroTier connectivity to BlueOS",
)
# app.router.route_class = GenericErrorHandlingRoute
logger.info("Starting ZeroTierManager!")


def run_command(command: str, check: bool = True) -> "subprocess.CompletedProcess['str']":
    return subprocess.run(
        command.split(),
        check=check,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


@app.post("/command/join", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_join(network: str) -> Any:
    command = f'zerotier-cli join {network}'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output.stdout or output.stderr

@app.post("/command/leave", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_leave(network: str) -> Any:
    command = f'zerotier-cli leave {network}'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output.stdout or output.stderr

@app.get("/command/info", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_info() -> Any:
    command = f'zerotier-cli info'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output.stdout or output.stderr

@app.get("/command/networks", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_info() -> Any:
    command = f'zerotier-cli listnetworks -j'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output.stdout or output.stderr

@app.get("/settings", status_code=status.HTTP_200_OK)
@version(1, 0)
async def read_conf() -> Any:
    try:
        with open('/var/lib/zerotier-one/local.conf', 'r') as f:
            return f.read()
    except:
        pass
    return "{}"

@app.post("/settings", status_code=status.HTTP_200_OK)
@version(1, 0)
async def write_conf(conf: Settings) -> Any:
  path = Path('/var/lib/zerotier-one/local.conf')
  path.parent.mkdir(parents=True, exist_ok=True)  # Ensure the directory exists
  with path.open('w') as f:
    f.write(conf.settings)
  return conf

app = VersionedFastAPI(app, version="1.0.0", prefix_format="/v{major}.{minor}", enable_latest=True)

app.mount("/", StaticFiles(directory="static", html=True), name="static")

if __name__ == "__main__":
    # Running uvicorn with log disabled so loguru can handle it
    uvicorn.run(app, host="0.0.0.0", port=9131, log_config=None)
