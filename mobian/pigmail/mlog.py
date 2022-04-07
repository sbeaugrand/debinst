# ---------------------------------------------------------------------------- #
## \file mlog.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
from os import path, rename


# ---------------------------------------------------------------------------- #
## \class MLog
# ---------------------------------------------------------------------------- #
class MLog:
    def __init__(self, filename, today, yesterday):
        self.filename = filename
        self.today = today
        self.yesterday = yesterday
        self.log = list()
        self.cur = None
        if path.exists(self.filename):
            rename(self.filename, self.filename + '.1')
            with open(self.filename + '.1', 'r') as f:
                for l in f.read().split('\n'):
                    s = l.split()
                    if len(s) == 2:
                        d, i = s
                        if d == self.today or d == self.yesterday:
                            if self.set(i):
                                self.append(d)

    def set(self, i):
        if i is None:
            return False
        elif i in self.log:
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
        with open(self.filename, 'a') as f:
            print('{} {}'.format(d, self.cur), file=f)
        self.cur = None
