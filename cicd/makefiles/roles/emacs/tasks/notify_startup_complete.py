#!/usr/bin/env python3
# ---------------------------------------------------------------------------- #
## \file notify_startup_complete.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import gi
gi.require_version('Gdk', '3.0')
from gi.repository import Gdk
Gdk.notify_startup_complete()
