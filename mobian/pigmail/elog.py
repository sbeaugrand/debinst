# ---------------------------------------------------------------------------- #
## \file elog.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
from os import path, unlink
from datetime import datetime


# ---------------------------------------------------------------------------- #
## \class ELog
# ---------------------------------------------------------------------------- #
class ELog:
    filename = None

    @staticmethod
    def clear():
        if path.exists(ELog.filename):
            unlink(ELog.filename)

    @staticmethod
    def perror(e, t):
        with open(ELog.filename, 'a') as f:
            d = datetime.now().strftime('%H:%M:%S')
            if t is None:
                print('{} {}'.format(d, e), file=f)
            else:
                print('{} {}:{}'.format(d, t, e), file=f)

    @staticmethod
    def read():
        if path.exists(ELog.filename):
            with open(ELog.filename, 'r') as f:
                return f.read()
        else:
            return ''


# ---------------------------------------------------------------------------- #
## \fn perror
# ---------------------------------------------------------------------------- #
def perror(e, t=None):
    ELog.perror(e, t)
