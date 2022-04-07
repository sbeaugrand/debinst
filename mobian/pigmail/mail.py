# ---------------------------------------------------------------------------- #
## \file mail.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
import email
import quopri
import traceback
from imap import *


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
    def __init__(self, imap, num, mlog):
        self.imap = imap
        self.mlog = mlog
        self.num = num
        self.body = b''
        self.offset = -1
        self.messageId = None
        self.eof = False
        self.fetch_header()
        self.err = None

    def fetch_header(self):
        try:
            tmp, data = self.imap.fetch(
                self.num,
                '(BODY[HEADER.FIELDS (DATE FROM SUBJECT MESSAGE-ID)])')
        except Exception as e:
            perror(e, 'fetch header')
            self.imap.start()
            tmp, data = self.imap.fetch(
                self.num, '(BODY[HEADER.FIELDS (FROM SUBJECT MESSAGE-ID)])')
        try:
            for d in data:
                if isinstance(d, tuple):
                    msg = email.message_from_string(d[1].decode())
                    self.headerDate = decode(msg['Date'])
                    self.headerFrom = decode(msg['From'])
                    self.headerSubject = decode(msg['Subject'])
                    self.messageId = decode(msg['Message-ID']).strip()
                    break
        except Exception as e:
            perror(e, 'message_from_string')
            perror(data, 'data')

    def fetch_part_number(self):
        tmp, data = self.imap.fetch(self.num, '(BODYSTRUCTURE)')
        self.structure = str(data[0]).split(')(')
        for n in range(len(self.structure)):
            if self.structure[n].find('"TEXT" "PLAIN"') >= 0:
                self.part = n + 1
                return self.part
        return 0

    def fetch_part(self):
        if self.offset < 0:
            self.offset = 0
            self.charset = self.structure[self.part - 1].split(
                'CHARSET" "')[1].split('"')[0]
        try:
            tmp, data = self.imap.fetch(
                self.num, 'BODY[{}]<{}.{}>'.format(self.part, self.offset,
                                                   256))
        except Exception as e:
            perror(e, 'fetch part')
            imap.start()
            tmp, data = self.imap.fetch(
                self.num, 'BODY[{}]<{}.{}>'.format(self.part, self.offset,
                                                   256))
        self.offset += 256
        if isinstance(data[0][1], int):
            self.eof = True
        else:
            self.body += data[0][1]
        if not self.body:
            perror('empty plain text')
            return ''
        try:
            array = quopri.decodestring(self.body)
        except Exception as e:
            perror(e, 'decodestring')
            array = self.body
        try:
            if array[-1] > 128:
                text = array[:-1].decode(self.charset, errors='replace')
            else:
                text = array.decode(self.charset, errors='replace')
        except Exception as e:
            perror(''.join(traceback.format_exception(None, e,
                                                      e.__traceback__)))
            self.err = ''.join(traceback.format_exception_only(None, e))
            text = str(array)
        if self.eof:
            return text + '\n'
        else:
            return text + '...\n'

    def fetch_preview(self):
        tmp, data = self.imap.fetch(self.num, '(PREVIEW)')
        self.eof = True
        try:
            return data[0][1].decode()
        except Exception as e:
            perror(e, 'preview')
            return data[0].decode()
