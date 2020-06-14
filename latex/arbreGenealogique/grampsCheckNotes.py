#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file grampsCheckNotes.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from gramps.gen.db import open_database
from os import path

# ---------------------------------------------------------------------------- #
## \fn is_int
# ---------------------------------------------------------------------------- #
def is_int(value):
    try:
        tempVal = int(value)
        return True
    except:
        return False

# ---------------------------------------------------------------------------- #
## \fn checkEvent
# ---------------------------------------------------------------------------- #
def checkEvent(eventRef):
    if eventRef is None:
        return 0
    event = db.get_event_from_handle(eventRef.get_reference_handle())
    id = event.get_gramps_id()
    if len(event.get_media_list()) > 0:
        if len(event.get_note_list()) == 0:
            str = "{0} (media sans note) {1}".format(id,
                db.get_media_from_handle(
                    event.get_media_list(
                        )[0].get_reference_handle()).get_path())
            if not str in supp:
                print(str)
                return 1
            else:
                supp.remove(str)
                return 0
        note = db.get_note_from_handle(
            event.get_note_list()[0]).get().replace("\n", " ")
        if not is_int(note.split("/")[0]) or\
           not is_int(note.split()[0].split("/")[1]):
            str = "{0} {1}".format(id, note)
            if not str in supp:
                print(str)
                return 1
            else:
                supp.remove(str)
                return 0
        if note.split()[1][:4] != "http":
            str = "{0} {1}".format(id, note)
            if not str in supp:
                print(str)
                return 1
            else:
                supp.remove(str)
                return 0
        if len(event.get_note_list()) > 1:
            note = db.get_note_from_handle(
                event.get_note_list()[1]).get().replace("\n", " ")
            str = "{0} (plusieurs notes) {1}".format(id, note)
            if not str in supp:
                print(str)
                return 1
            else:
                supp.remove(str)
                return 0
    else:
        if len(event.get_note_list()) > 0:
            note = db.get_note_from_handle(
                event.get_note_list()[0]).get().replace("\n", " ")
            str = "{0} (note sans media) {1}".format(id, note)
            if not str in supp:
                print(str)
                return 1
            else:
                supp.remove(str)
                return 0
        if event.place:
            str = "{0} (lieu sans note) {1} {2}".format(id,
                db.get_place_from_handle(event.place).name.value,
                event.date.text)
            if event.description:
                str += " ({0})".format(event.description)
            if not str in supp:
                print(str)
                return 1
            else:
                supp.remove(str)
                return 0
        if not event.date.is_empty():
            str = "{0} (date sans note) {1}".format(id, event.date.text)
            if event.description:
                str += " ({0})".format(event.description)
            if not str in supp:
                print(str)
                return 1
            else:
                supp.remove(str)
                return 0
    return 0

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
    sum = 0
    sum += checkEvent(person.get_birth_ref())
    sum += checkEvent(person.get_death_ref())
    if level >= depth:
        return sum
    for handle in person.get_parent_family_handle_list():
        family = db.get_family_from_handle(handle)
        for ref in family.get_event_ref_list():
            if db.get_event_from_handle(
                ref.get_reference_handle()).get_type().is_marriage():
                sum += checkEvent(ref)
        sum += checkParent(family.get_father_handle(), level, depth)
        sum += checkParent(family.get_mother_handle(), level, depth)
    return sum

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
db = open_database(sys.argv[1], force_unlock=True)
person = db.get_default_person()
print(" default person:", person.get_primary_name().get_name())
if path.isfile("gramps-pr-checkNotes.supp"):
    suppFile = open("gramps-pr-checkNotes.supp", "r")
    supp = suppFile.read().splitlines()
    suppFile.close()
else:
    supp = list()
print(" nb of notes to check:", checkPerson(person, 1, int(sys.argv[2])))
db.close()
if len(supp) > 0:
    print(supp)
