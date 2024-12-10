#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file git-pull.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import subprocess
import uvicorn
from fastapi import FastAPI

app = FastAPI()


@app.post('/{group}/{proj}')
async def post_pull(group: str, proj: str) -> str:
    return subprocess.check_output(
        f'cd /mnt/repos/{group}/{proj} && git pull', shell=True)


uvicorn.run(app, host="0.0.0.0", port=8000)
