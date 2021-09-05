#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file mail2sms.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note encoded_words_to_text: https://dmorgan.info/posts/encoded-word-syntax/
# ---------------------------------------------------------------------------- #
import re
import base64
import quopri
import sys

def encoded_words_to_text(encoded_words):
    encoded_word_regex = r'=\?{1}(.+)\?{1}([B|Q])\?{1}(.+)\?{1}='
    result = re.match(encoded_word_regex, encoded_words)
    if result:
        charset, encoding, encoded_text = result.groups()
        if encoding is 'B':
            byte_string = base64.b64decode(encoded_text)
        elif encoding is 'Q':
            byte_string = quopri.decodestring(encoded_text)
        return byte_string.decode(charset)
    else:
        return encoded_words

sms = ''
line = sys.stdin.readline()
while line:
    if line.startswith('From:'):
        sms += line.split(maxsplit=1)[1]
    if line.startswith('Subject:'):
        sms += encoded_words_to_text(line.split(maxsplit=1)[1])
        line = sys.stdin.readline()
        if line.startswith(' '):
            sms += encoded_words_to_text(line.strip())
        break
    line = sys.stdin.readline()

print(sms[:160])
