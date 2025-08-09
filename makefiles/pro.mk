# ---------------------------------------------------------------------------- #
## \file pro.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/pro.mk
PROJECT   ?= $(shell basename `readlink -f .`)

ifeq ($(wildcard kicad),kicad)
 TARDEPEND += kicad
endif
