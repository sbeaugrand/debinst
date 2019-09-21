# ---------------------------------------------------------------------------- #
## \file dat2svg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Install:
#
# apt install python-configparser python3-numpy python3-gi-cairo gir1.2-gtk-3.0
# ---------------------------------------------------------------------------- #
# Debug:
#
# sudo pip install -t /usr/local/lib/python3.4/dist-packages hunter
# vi pyBar.py +1 +/--
#  import hunter
#  hunter.trace(module='classDrawing', action=hunter.CallPrinter)
# ---------------------------------------------------------------------------- #
from pyBar import MainWindow
mw = MainWindow()
mw._ini_drawing_page(0)
mw.active_tab.add_study(
  path=src,
  options={'Series': False,
           'Title': True,
           'Barre': True,
           'Node': True,
           'Axis': False})
mw.active_tab.get_layout_size(list(mw.active_tab.drawings.values()))
mw._export_svg(dst)
