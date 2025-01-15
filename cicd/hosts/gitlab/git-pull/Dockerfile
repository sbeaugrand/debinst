# ---------------------------------------------------------------------------- #
## \file Dockerfile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
FROM python:slim

RUN apt-get -y update\
 && apt-get -y install git

COPY requirements.txt .
RUN pip install -r requirements.txt && rm requirements.txt

RUN git config --global pull.rebase true

COPY git-pull.py .

EXPOSE 8000

ENTRYPOINT ["python", "git-pull.py"]
