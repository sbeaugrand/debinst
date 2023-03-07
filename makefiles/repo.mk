# ---------------------------------------------------------------------------- #
## \file repo.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND  += makefiles/repo.mk

.SUFFIXES:

ifeq ($(idir),)
 REPO = $(HOME)/install/repo
else
 REPO = $(idir)/../repo
endif
BDIR  = $(HOME)/data/install-build

$(shell mkdir -p $(REPO))
$(shell mkdir -p $(BDIR))
