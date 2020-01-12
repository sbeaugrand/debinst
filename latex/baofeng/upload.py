# ---------------------------------------------------------------------------- #
## \file upload.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
from chirp.drivers import uv5r
from chirp.drivers import uv6r
from chirp.drivers import baofeng_wp970i  # UV-9R+
# open
from gettext import NullTranslations
t = NullTranslations()
t.install()
from chirp.ui import mainapp
a = mainapp.ChirpMain()
a.do_open(img)
# import
eset = a.get_current_editorset()
count = eset.do_import(csv)
if (count > 0):
    print 'error: import'
    exit(1)
# upload
a.do_upload(port=port, rtype=rtype)
