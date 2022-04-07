# ---------------------------------------------------------------------------- #
## \file imap.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
import imaplib
import keyring
from time import sleep
from elog import *


# ---------------------------------------------------------------------------- #
## \class Imap
# ---------------------------------------------------------------------------- #
class Imap:
    def __init__(self, host, user, inbox):
        self.host = host
        self.user = user
        self.inbox = inbox
        while True:
            try:
                self.passwd = keyring.get_password(self.host, self.user)
                break
            except Exception as e:
                perror(e, 'keyring')
                sleep(60)

    def start(self):
        while True:
            try:
                self.imap = imaplib.IMAP4_SSL(self.host)
                self.imap.login(self.user, self.passwd)
                self.imap.select(self.inbox)
                break
            except Exception as e:
                perror(e, 'imap new')
                sleep(300)

    def search_since(self, d):
        return self.imap.search(None, '(SINCE "{}")'.format(d))

    def fetch(self, n, s):
        return self.imap.fetch(n, s)

    def noop(self):
        self.imap.noop()

    def move(self, n, d):
        r = self.imap.copy(n, d)
        if r[0] == 'NO':
            perror(r, 'imap copy')
            return
        r = self.imap.store(n, '+FLAGS', '(\\Deleted)')
        if r[0] == 'NO':
            perror(r, 'imap store')
            return
        r = self.imap.expunge()
        if r[0] == 'NO':
            perror(r, 'imap expunge')
            return
