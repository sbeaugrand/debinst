# ---------------------------------------------------------------------------- #
## \file plog.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
from os import path, unlink, getpid, kill


# ---------------------------------------------------------------------------- #
## \class PLog
# ---------------------------------------------------------------------------- #
class PLog:
    def __init__(self, filename):
        self.filename = filename
        self.pid = None

    def read(self):
        if path.exists(self.filename):
            with open(self.filename, 'r') as f:
                self.pid = int(f.read())
            if not path.isdir('/proc/{}'.format(self.pid)):
                self.pid = None
                self.unlink()
        return self.pid

    def write(self):
        with open(self.filename, 'w') as f:
            f.write('{}'.format(getpid()))

    def kill(self):
        if self.pid is not None:
            kill(self.pid, 15)

    def unlink(self):
        if path.exists(self.filename):
            unlink(self.filename)
