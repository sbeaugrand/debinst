# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
PROJECT = django-wiki
PROPATH = wiki

.SUFFIXES:

.PHONY: all
all:
	@echo "Usage: make install"

.PHONY: install
install:
	@$(PROROOT)/../0install.sh install-op-$(PROJECT).sh

include ${PROROOT}/makefiles/tar.mk
