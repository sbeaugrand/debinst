#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file grampsReplaceLineFeed.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from gramps.gen.db import open_database
from gramps.gen.db.txn import DbTxn

def is_int(value):
    try:
        tempVal = int(value)
        return True
    except:
        return False

db = open_database(sys.argv[1], force_unlock=True)
count = 0
with DbTxn("Replace line feed", db, batch=True) as transaction:
    for obj in db.iter_notes():
        text = obj.get()
        pos = text.find("\nhttp")
        if pos > 0 and is_int(text[pos - 1:pos]):
            text = text.replace("\nhttp", " http", 1)
            obj.set(text)
            db.commit_note(obj, transaction)
            count += 1
            print(text)
db.close()
if count > 0:
    print(count)
