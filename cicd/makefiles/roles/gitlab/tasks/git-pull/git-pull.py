#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file git-pull.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import subprocess
import uvicorn
import os
from fastapi import FastAPI

app = FastAPI()


@app.post('/{group}/{project}')
async def post_pull(group: str, project: str, token: str) -> str:
    path = f'/mnt/repos/{group}/{project}'
    if os.path.isdir(path):
        return subprocess.check_output(f'cd {path} && git pull', shell=True)
    else:
        os.makedirs(f'/mnt/repos/{group}', exist_ok=True)
        return subprocess.check_output(
            f'cd /mnt/repos/{group} && git clone https://:{token}@gitlab.{{ domain }}/{group}/{project}.git',
            shell=True)


uvicorn.run(app, host="0.0.0.0", port=8000)
