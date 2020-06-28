#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file grampsCheckMedias.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from os import path, walk
from gramps.gen.db import open_database

db = open_database(sys.argv[1], force_unlock=True)
medias = list()
count = 0
for media in db.iter_media():
    medias.append(path.basename(media.path))
files = next(walk(sys.argv[2]))[2]
for filename in files:
    if not filename in medias:
        print(filename)
        count += 1
    else:
        medias = [f for f in medias if f != filename]
db.close()
if count > 0:
    print(count)
if len(medias) > 0:
    print(medias)

