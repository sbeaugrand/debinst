#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file grampsCheckNotes.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import sys
from gramps.gen.db import open_database

def is_int(value):
    try:
        tempVal = int(value)
        return True
    except:
        return False

def checkEvent(eventRef):
    if eventRef is None:
        return 0
    event = db.get_event_from_handle(eventRef.get_reference_handle())
    id = event.get_gramps_id()
    if len(event.get_media_list()) > 0:
        if len(event.get_note_list()) == 0:
            print(id, "(media sans note)", db.get_media_from_handle(
                event.get_media_list()[0].get_reference_handle()).get_path())
            return 1
        note = db.get_note_from_handle(
            event.get_note_list()[0]).get().replace("\n", " ")
        if not is_int(note.split("/")[0]) or\
           not is_int(note.split()[0].split("/")[1]):
            print(id, note)
            return 1
        if note.split()[1][:4] != "http":
            print(id, note)
            return 1
        if len(event.get_note_list()) > 1:
            note = db.get_note_from_handle(
                event.get_note_list()[1]).get().replace("\n", " ")
            print(id, "(plusieurs notes)", note)
            return 1
    else:
        if len(event.get_note_list()) > 0:
            note = db.get_note_from_handle(
                event.get_note_list()[0]).get().replace("\n", " ")
            print(id, "(note sans media)", note)
            return 1
        if event.place:
            print(id, "(lieu sans note)", event.description)
            return 1
        if event.date.is_valid():
            print(id, "(date sans note)", event.description)
            return 1
    return 0

def checkParent(handle, level, depth):
    if db.has_person_handle(handle):
        return checkPerson(db.get_person_from_handle(handle), level + 1, depth)
    return 0

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

db = open_database(sys.argv[1], force_unlock=True)
person = db.get_default_person()
print(" default person:", person.get_primary_name().get_name())
print(" nb of notes to check:", checkPerson(person, 1, int(sys.argv[2])))
db.close()
