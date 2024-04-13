# ---------------------------------------------------------------------------- #
## \file expect.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import pexpect
import time
import sys

lserver = sys.argv[1]
verbose = True if len(sys.argv) > 2 and sys.argv[2] == '-v' else False
err = False


class Server:

    def __init__(self):
        self.s = pexpect.spawn('build/project-four')
        time.sleep(1)

    def __del__(self):
        if err:
            return
        self.s.expect(pexpect.EOF)


class send:

    def __init__(self, method):
        if err:
            return
        self.c = pexpect.spawn('client.py {} {}'.format(lserver, method))
        if verbose:
            self.c.logfile = sys.stdout.buffer

    def __del__(self):
        if err:
            return
        self.c.expect(pexpect.EOF)

    def expect(self, s):
        global err
        if err:
            return
        try:
            self.c.expect_exact('{}\r\n'.format(s))
        except:
            err = True
            raise


s = Server()
