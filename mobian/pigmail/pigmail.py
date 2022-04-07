#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file pigmail.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
import threading
from os import system, getenv
from datetime import date, timedelta
today = date.today()
yesterday = today - timedelta(days=1)
today = today.strftime('%d-%b-%Y')
yesterday = yesterday.strftime('%d-%b-%Y')

from gui import *

import gi
gi.require_version('Lfb', '0.0')
from gi.repository import Lfb
Lfb.init(APP_ID)


# ---------------------------------------------------------------------------- #
## \fn trigger_event
# ---------------------------------------------------------------------------- #
def trigger_event(name):
    ev = Lfb.Event.new(name)
    ev.trigger_feedback()
    if path.exists('/usr/bin/wtype'):
        system('/usr/bin/wtype -M shift -m shift')
    elif path.exists('/usr/bin/xdotool'):
        system('/usr/bin/xdotool key shift')


# ---------------------------------------------------------------------------- #
## \fn noop_task
# ---------------------------------------------------------------------------- #
def noop_task():
    global imap
    global event
    while True:
        event.wait()
        sleep(100)
        if event.is_set():
            try:
                imap.noop()
            except Exception as e:
                perror(e, 'imap noop')
                event.clear()


# ---------------------------------------------------------------------------- #
## \fn loop
# ---------------------------------------------------------------------------- #
def loop():
    global imap
    global event
    try:
        tmp, messages = imap.search_since(yesterday)
    except Exception as e:
        perror(e, 'imap search')
        imap.start()
        tmp, messages = imap.search_since(yesterday)
    for num in messages[0].split():
        mail = Mail(imap, num, mlog)
        if not mlog.set(mail.messageId):
            continue
        if mail.fetch_part_number() > 0:
            text = mail.fetch_part()
            if not text:
                text = mail.fetch_preview()
        else:
            text = mail.fetch_preview()
        trigger_event('message-new-instant')
        event.set()
        gui_mail_rx(text, mail)
        event.clear()


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
# elog / plog
rundir = getenv('XDG_RUNTIME_DIR')
ELog.filename = rundir + '/pigmail.err'
plog = PLog(rundir + '/pigmail.pid')
if plog.read() is not None:
    gui_status_box(plog)
    exit(0)
else:
    gui_status_box()
plog.write()
ELog.clear()

# mlog
mlog = MLog(LOG_FILE, today, yesterday)

# noop_task
event = threading.Event()
thread = threading.Thread(target=noop_task, daemon=True)
thread.start()

# imap
imap = Imap(IMAP_HOST, IMAP_USER, BOX_INBOX)
imap.start()

# loop
while True:
    try:
        loop()
    except Exception as e:
        s = ''.join(traceback.format_exception(None, e, e.__traceback__))
        perror(s)
        try:
            gui_notify_exception()
        except Exception as e:
            perror(e, 'on_activate_notification')
        trigger_event('dialog-warning')
        mlog.append()
        event.clear()
        sleep(300)
        continue
    event.set()
    sleep(250)
    event.clear()
    sleep(50)
