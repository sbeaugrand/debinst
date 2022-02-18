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
from os import path, rename
from time import sleep
from datetime import date, timedelta
today = date.today()
yesterday = today - timedelta(days=1)
today = today.strftime("%d-%b-%Y")
yesterday = yesterday.strftime("%d-%b-%Y")

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
while not Gtk.init_check():
    sleep(60)
gi.require_version('GSound', '1.0')
from gi.repository import GLib, GSound
sound = GSound.Context()
sound.init()

import keyring
exec(open('user-pr-config.py').read())
while True:
    try:
        imapPass = keyring.get_password(imapHost, imapUser)
        break
    except Exception as e:
        print(e, file=sys.stderr)
        sleep(60)


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
        return e.args[1]


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
            print(e, file=sys.stderr)
            imap = imaplib.IMAP4_SSL(imapHost)
            imap.login(imapUser, imapPass)
            imap.select('inbox')
            tmp, data = imap.fetch(
                self.num, '(BODY[HEADER.FIELDS (FROM SUBJECT MESSAGE-ID)])')
        msg = email.message_from_string(data[0][1].decode())
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
            print(e, file=sys.stderr)
            imap = imaplib.IMAP4_SSL(imapHost)
            imap.login(imapUser, imapPass)
            imap.select('inbox')
            tmp, data = imap.fetch(
                self.num, 'BODY[{}]<{}.{}>'.format(self.part, self.offset,
                                                   256))
        self.offset += 256
        if not isinstance(data[0][1], int):
            self.body += data[0][1]
        if self.charset.upper() == 'UTF-8':
            text = quopri.decodestring(self.body).decode()
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
        except:
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
## \fn onButtonPlus
# ---------------------------------------------------------------------------- #
def onButtonPlus(widget, textview, mail):
    if mail.offset >= 0:
        buff = textview.get_buffer()
        bufferText(buff, mail.fetchPart(), mail)
        textview.scroll_to_mark(buff.get_insert(), 0.0, True, 0.0, 1.0)


# ---------------------------------------------------------------------------- #
## \fn messageText
# ---------------------------------------------------------------------------- #
def messageText(text, mail):
    global sound
    sound.play_simple({GSound.ATTR_EVENT_ID: "message-new-instant"})
    window = Gtk.Window()
    window.set_title('Python Imap Gtk Mail')
    window.set_default_size(WIDTH, HEIGHT)
    window.connect('delete-event', Gtk.main_quit)
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
    buttonPlus = Gtk.Button(label="+")
    buttonPlus.connect("clicked", onButtonPlus, textview, mail)
    hbox.pack_start(buttonPlus, True, True, 0)
    buttonMoins = Gtk.Button(label="-")
    buttonMoins.connect("clicked", lambda x: window.close())
    hbox.pack_start(buttonMoins, True, True, 0)
    vbox.pack_start(hbox, True, True, 0)
    Gtk.Widget.set_size_request(scrolled, WIDTH, HEIGHT - 80)
    window.show_all()
    Gtk.main()


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
## \fn loop
# ---------------------------------------------------------------------------- #
def loop():
    global imap
    global log
    try:
        imap = imaplib.IMAP4_SSL(imapHost)
        imap.login(imapUser, imapPass)
        imap.select('inbox')
        tmp, messages = imap.search(None, '(SINCE "{}")'.format(yesterday))
    except Exception as e:
        print(e, file=sys.stderr)
        return
    for num in messages[0].split():
        mail = Mail(num)
        i = mail.messageId
        if not log.set(i):
            continue
        if mail.fetchPartNumber() > 0:
            messageText(mail.fetchPart(), mail)
        else:
            messageText(mail.fetchPreview(), mail)
        log.append()
    try:
        imap.close()
        imap.logout()
    except Exception as e:
        print(e, file=sys.stderr)


# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
log = Log(today, yesterday)
while True:
    try:
        loop()
    except Exception as e:
        s = ''.join(traceback.format_exception(None, e, e.__traceback__))
        try:
            dialog = Gtk.MessageDialog(modal=True,
                                       message_type=Gtk.MessageType.ERROR,
                                       buttons=Gtk.ButtonsType.OK_CANCEL,
                                       text=s)
            r = dialog.run()
            dialog.destroy()
            if r == Gtk.ResponseType.CANCEL:
                log.append()
            while Gtk.events_pending():
                Gtk.main_iteration()
        except:
            print(s, file=sys.stderr)
    sleep(300)
