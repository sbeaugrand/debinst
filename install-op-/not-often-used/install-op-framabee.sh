# ---------------------------------------------------------------------------- #
## \file install-op-framabee.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
sudo -u $user firefox `python -c "
from base64 import urlsafe_b64encode, urlsafe_b64decode
from zlib import compress, decompress

#prefs = ''
#print decompress(urlsafe_b64decode(prefs.encode('utf-8')))

prefs = 'language=fr-FR&locale=fr'
print 'https://framabee.org/preferences?preferences=' +\
    urlsafe_b64encode(compress(prefs.encode('utf-8'))).decode('utf-8')
"`
