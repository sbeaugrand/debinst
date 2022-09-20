# ---------------------------------------------------------------------------- #
## \file dat2svg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Debug:
#
# pip3 install hunter
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
mw.active_tab.area_w = 0
mw.active_tab.area_h = 0
mw.active_tab.get_layout_size(list(mw.active_tab.drawings.values()))
mw._export_svg(dst)
