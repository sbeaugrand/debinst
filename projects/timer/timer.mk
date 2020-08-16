# ---------------------------------------------------------------------------- #
## \file timer.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += timer
TARDEPEND += makefiles/ccpp.mk# tests
CFLAGS += -I$(PROROOT)/timer
CPPCHECKINC += -I$(PROROOT)/timer
