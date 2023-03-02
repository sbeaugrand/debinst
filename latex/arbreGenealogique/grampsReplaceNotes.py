#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file grampsReplaceNotes.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from gramps.gen.db import open_database
from gramps.gen.db.txn import DbTxn

db = open_database(sys.argv[1], force_unlock=True)
count = 0
with DbTxn("Replace notes", db, batch=True) as transaction:
    for obj in db.iter_notes():
        text = obj.get()
        if text.find("http://archives.archinoe.com/cg77") >= 0:
            text = text.replace(
                "http://archives.archinoe.com/cg77",
                "http://archives-en-ligne.seine-et-marne.fr/mdr")
            obj.set(text)
            db.commit_note(obj, transaction)
            count += 1
            print(text.replace("\n", " "))
        elif text.find("https://consultation.archives-loiret.fr/") >= 0:
            text = text.replace(
                "https://consultation.archives-loiret.fr/",
                "https://archives-loiret.fr/")
            obj.set(text)
            db.commit_note(obj, transaction)
            count += 1
            print(text.replace("\n", " "))
db.close()
if count > 0:
    print(count)
