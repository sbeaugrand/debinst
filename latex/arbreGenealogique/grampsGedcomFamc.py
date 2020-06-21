#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file grampsGedcomFamc.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from gramps.gen.db import open_database
from os import path

# ---------------------------------------------------------------------------- #
## \fn checkParent
# ---------------------------------------------------------------------------- #
def checkParent(handle, level, depth):
    if db.has_person_handle(handle):
        return checkPerson(db.get_person_from_handle(handle), level + 1, depth)
    return 0

# ---------------------------------------------------------------------------- #
## \fn checkPerson
# ---------------------------------------------------------------------------- #
def checkPerson(person, level, depth):
    if level > depth:
        return sum
    for handle in person.get_parent_family_handle_list():
        family = db.get_family_from_handle(handle)
        if level == depth:
            print(family.gramps_id)
            return
        checkParent(family.get_father_handle(), level, depth)
        checkParent(family.get_mother_handle(), level, depth)

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
db = open_database(sys.argv[1], force_unlock=True)
person = db.get_default_person()
checkPerson(person, 1, int(sys.argv[2]))
db.close()
