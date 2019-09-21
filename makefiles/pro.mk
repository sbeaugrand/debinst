# ---------------------------------------------------------------------------- #
## \file pro.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/pro.mk

ifeq "$(PROJECT)" ""
 PROJECT = $(shell basename `readlink -f .`)
endif
ifeq "$(wildcard kicad)" "kicad"
 TARDEPEND += kicad
endif
