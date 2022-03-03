#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file pigmail.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
import imaplib
import email
import quopri
import html
import traceback
import sys
import threading
from os import path, rename, system
from time import sleep
from datetime import date, timedelta
today = date.today()
yesterday = today - timedelta(days=1)
today = today.strftime("%d-%b-%Y")
yesterday = yesterday.strftime("%d-%b-%Y")

applicationId = 'com.github.sbeaugrand.pigmail'
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gio
while not Gtk.init_check():
    sleep(60)
gi.require_version('Lfb', '0.0')
from gi.repository import Lfb
Lfb.init(applicationId)

import keyring


# ---------------------------------------------------------------------------- #
## \fn perror
# ---------------------------------------------------------------------------- #
def perror(e, t=None):
    if t is None:
        print(e, file=sys.stderr)
    else:
        print('{}:{}'.format(t, e), file=sys.stderr)


# ---------------------------------------------------------------------------- #
## \fn decode
# ---------------------------------------------------------------------------- #
def decode(h):
    line = ''
    try:
        for s in email.header.decode_header(h):
            if s[1]:
                line += s[0].decode(s[1]) + ' '
            elif isinstance(s[0], str):
                line += s[0] + ' '
            else:
                line += s[0].decode() + ' '
        return line.replace('  ', ' ')
    except Exception as e:
        return ''.join(traceback.format_exception_only(None, e))


# ---------------------------------------------------------------------------- #
## \class Mail
# ---------------------------------------------------------------------------- #
class Mail:
    def __init__(self, num):
        self.num = num
        self.body = b''
        self.offset = -1
        self.fetchHeader()

    def fetchHeader(self):
        global imap
        try:
            tmp, data = imap.fetch(
                self.num,
                '(BODY[HEADER.FIELDS (DATE FROM SUBJECT MESSAGE-ID)])')
        except Exception as e:
            perror(e)
            imap = Imap()
            tmp, data = imap.fetch(
                self.num, '(BODY[HEADER.FIELDS (FROM SUBJECT MESSAGE-ID)])')
        try:
            msg = email.message_from_string(data[0][1].decode())
        except Exception as e:
            perror(e, 'message_from_string')
            msg = email.message_from_string(data[1][1].decode())
        if not isinstance(msg['Date'], str) and not isinstance(
                msg['Date'], bytes):
            perror(data, 'data')
        self.headerDate = decode(msg['Date'])
        self.headerFrom = decode(msg['From'])
        self.headerSubject = decode(msg['Subject'])
        self.messageId = decode(msg['Message-ID']).strip()

    def fetchPartNumber(self):
        global imap
        tmp, data = imap.fetch(self.num, '(BODYSTRUCTURE)')
        self.structure = str(data[0]).split(')(')
        for n in range(len(self.structure)):
            if self.structure[n].find('"TEXT" "PLAIN"') >= 0:
                self.part = n + 1
                return self.part
        return 0

    def fetchPart(self):
        global imap
        if self.offset < 0:
            self.offset = 0
            self.charset = self.structure[self.part - 1].split(
                'CHARSET" "')[1].split('"')[0]
        try:
            tmp, data = imap.fetch(
                self.num, 'BODY[{}]<{}.{}>'.format(self.part, self.offset,
                                                   256))
        except Exception as e:
            perror(e)
            imap = Imap()
            tmp, data = imap.fetch(
                self.num, 'BODY[{}]<{}.{}>'.format(self.part, self.offset,
                                                   256))
        self.offset += 256
        if not isinstance(data[0][1], int):
            self.body += data[0][1]
        if self.charset.upper() == 'UTF-8':
            try:
                text = quopri.decodestring(self.body).decode()
            except Exception as e:
                perror(e, 'decodestring')
                text = self.body.decode()
        else:
            text = self.body.decode(self.charset)
        if isinstance(data[0][1], int):
            return text + '\n'
        elif ord(text[-1]) > 128:
            return text[:-1] + '...\n'
        else:
            return text + '...\n'

    def fetchPreview(self):
        global imap
        tmp, data = imap.fetch(self.num, '(PREVIEW)')
        try:
            return data[0][1].decode()
        except Exception as e:
            perror(e, 'preview')
            return data[0].decode()


# ---------------------------------------------------------------------------- #
## \fn bufferText
# ---------------------------------------------------------------------------- #
def bufferText(buff, text, mail):
    buff.set_text(mail.headerDate)
    buff.insert_markup(
        buff.get_end_iter(),
        '\n<span color="green">{}</span>\n<span color="yellow">{}</span>\n'.
        format(html.escape(mail.headerFrom),
               html.escape(mail.headerSubject)), -1)
    while True:
        i = text.find('http')
        if i < 0:
            break
        buff.insert(buff.get_end_iter(),
                    html.unescape(text[:i].replace('=\x0D', '')) + '(lien)')
        while i < len(text):
            if text[i].isspace():
                break
            i += 1
        text = text[i:]
    buff.insert(buff.get_end_iter(), html.unescape(text.replace('=\x0D', '')))
    buff.insert_markup(
        buff.get_end_iter(), '''
            <span font="monospace" color="pink">
             ^..^
            ( oo )  )~
              ,,  ,,     pigmail</span>
            ''', -1)


# ---------------------------------------------------------------------------- #
## \fn onButtonCont
# ---------------------------------------------------------------------------- #
def onButtonCont(widget, textview, mail):
    if mail.offset >= 0:
        buff = textview.get_buffer()
        bufferText(buff, mail.fetchPart(), mail)
        textview.scroll_to_mark(buff.get_insert(), 0.0, True, 0.0, 1.0)


# ---------------------------------------------------------------------------- #
## \fn onButtonSeen
# ---------------------------------------------------------------------------- #
def onButtonSeen(widget, window):
    global log
    log.append()
    window.close()


# ---------------------------------------------------------------------------- #
## \fn onButtonTrash
# ---------------------------------------------------------------------------- #
def onButtonTrash(widget, window, mail):
    global imap
    imap.move(mail.num, BOX_TRASH)
    window.close()


# ---------------------------------------------------------------------------- #
## \fn onButtonArchive
# ---------------------------------------------------------------------------- #
def onButtonArchive(widget, window, mail):
    global imap
    imap.move(mail.num, BOX_ARCHIVE)
    window.close()


# ---------------------------------------------------------------------------- #
## \fn onActivate
# ---------------------------------------------------------------------------- #
def onActivate(app, text, mail):
    global sound
    while True:
        try:
            window = Gtk.ApplicationWindow.new(app)
            break
        except Exception as e:
            perror(e)
            sleep(60)
    window.set_title('Python Imap Gtk Mail')
    window.set_default_size(WIDTH, HEIGHT)
    scrolled = Gtk.ScrolledWindow()
    textview = Gtk.TextView()
    textview.set_wrap_mode(Gtk.WrapMode.WORD)
    textview.set_editable(False)
    textview.set_cursor_visible(False)
    buff = textview.get_buffer()
    scrolled.add(textview)
    bufferText(buff, text, mail)
    vbox = Gtk.Box.new(Gtk.Orientation.VERTICAL, 5)
    vbox.pack_start(scrolled, True, True, 0)
    window.add(vbox)
    hbox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 5)
    buttonCont = Gtk.Button(label=BTN_CONT)
    buttonCont.connect("clicked", onButtonCont, textview, mail)
    hbox.pack_start(buttonCont, True, True, 0)
    buttonSeen = Gtk.Button(label=BTN_SEEN)
    buttonSeen.connect("clicked", onButtonSeen, window)
    hbox.pack_start(buttonSeen, True, True, 0)
    buttonArchive = Gtk.Button(label=BTN_ARCHIVE)
    buttonArchive.connect("clicked", onButtonArchive, window, mail)
    hbox.pack_start(buttonArchive, True, True, 0)
    buttonTrash = Gtk.Button(label=BTN_TRASH)
    buttonTrash.connect("clicked", onButtonTrash, window, mail)
    hbox.pack_start(buttonTrash, True, True, 0)
    vbox.pack_start(hbox, True, True, 0)
    Gtk.Widget.set_size_request(scrolled, WIDTH, HEIGHT - 80)
    window.show_all()
    notification = Gio.Notification()
    notification.set_title('Nouveau message de {}'.format(mail.headerFrom))
    app.send_notification(None, notification)


# ---------------------------------------------------------------------------- #
## \fn messageText
# ---------------------------------------------------------------------------- #
def messageText(text, mail):
    global event
    event.set()
    app = Gtk.Application(application_id=applicationId)
    app.connect('activate', onActivate, text, mail)
    ev = Lfb.Event.new('message-new-instant')
    ev.trigger_feedback()
    if path.exists('/usr/bin/wtype'):
        system('/usr/bin/wtype -M shift -m shift')
    elif path.exists('/usr/bin/xdotool'):
        system('/usr/bin/xdotool key shift')
    try:
        app.run()
    finally:
        event.clear()


# ---------------------------------------------------------------------------- #
## \class Log
# ---------------------------------------------------------------------------- #
class Log:
    def __init__(self, today, yesterday):
        self.today = today
        self.yesterday = yesterday
        self.log = list()
        self.cur = None
        if path.exists(LOG_FILE):
            rename(LOG_FILE, LOG_FILE + '.1')
            with open(LOG_FILE + '.1', 'r') as f:
                for l in f.read().split('\n'):
                    s = l.split()
                    if len(s) == 2:
                        d, i = s
                        if d == self.today or d == self.yesterday:
                            if self.set(i):
                                self.append(d)

    def set(self, i):
        if i in self.log:
            return False
        else:
            self.cur = i
            return True

    def append(self, d=None):
        if self.cur is None:
            return
        if d is None:
            d = self.today
        self.log.append(self.cur)
        with open(LOG_FILE, 'a') as f:
            print('{} {}'.format(d, self.cur), file=f)
        self.cur = None


# ---------------------------------------------------------------------------- #
## \class Imap
# ---------------------------------------------------------------------------- #
class Imap:
    def __init__(self):
        global imapHost
        global imapUser
        global imapPass
        self.imap = imaplib.IMAP4_SSL(imapHost)
        self.imap.login(imapUser, imapPass)
        self.imap.select(BOX_INBOX)

    def searchSince(self, d):
        return self.imap.search(None, '(SINCE "{}")'.format(d))

    def fetch(self, n, s):
        return self.imap.fetch(n, s)

    def noop(self):
        self.imap.noop()

    def move(self, n, d):
        r = self.imap.copy(n, d)
        if r[0] == 'NO':
            perror(r, 'imap.copy')
            return
        r = self.imap.store(n, '+FLAGS', '(\\Deleted)')
        if r[0] == 'NO':
            perror(r, 'imap.store')
            return
        r = self.imap.expunge()
        if r[0] == 'NO':
            perror(r, 'imap.expunge')
            return


# ---------------------------------------------------------------------------- #
## \fn loop
# ---------------------------------------------------------------------------- #
def loop():
    global imap
    global log
    try:
        tmp, messages = imap.searchSince(yesterday)
    except Exception as e:
        perror(e)
        imap = Imap()
        tmp, messages = imap.searchSince(yesterday)
    for num in messages[0].split():
        mail = Mail(num)
        i = mail.messageId
        if not log.set(i):
            continue
        if mail.fetchPartNumber() > 0:
            messageText(mail.fetchPart(), mail)
        else:
            messageText(mail.fetchPreview(), mail)


# ---------------------------------------------------------------------------- #
## \fn noopTask
# ---------------------------------------------------------------------------- #
def noopTask():
    global event
    global imap
    while True:
        event.wait()
        sleep(100)
        if event.is_set():
            try:
                imap.noop()
            except Exception as e:
                perror(e)
                event.clear()


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
exec(open('user-pr-config.py').read())
while True:
    try:
        imapPass = keyring.get_password(imapHost, imapUser)
        break
    except Exception as e:
        perror(e)
        sleep(60)

log = Log(today, yesterday)
event = threading.Event()
thread = threading.Thread(target=noopTask, daemon=True)
thread.start()

while True:
    try:
        imap = Imap()
        break
    except Exception as e:
        perror(e)
        sleep(300)
while True:
    try:
        loop()
    except Exception as e:
        s = ''.join(traceback.format_exception(None, e, e.__traceback__))
        perror(s)
        try:
            if log.cur is None:
                b = Gtk.ButtonsType.CLOSE
            else:
                b = Gtk.ButtonsType.YES_NO
                e = ''.join(traceback.format_exception_only(
                    None, e)) + '\nRessayer dans 5 min ?'
            dialog = Gtk.MessageDialog(modal=True,
                                       message_type=Gtk.MessageType.ERROR,
                                       buttons=b,
                                       text=e)
            event.set()
            r = dialog.run()
            dialog.destroy()
            if r == Gtk.ResponseType.NO:
                log.append()
            while Gtk.events_pending():
                Gtk.main_iteration()
        except Exception as e:
            perror(e)
        finally:
            event.clear()
    event.set()
    sleep(250)
    event.clear()
    sleep(50)
