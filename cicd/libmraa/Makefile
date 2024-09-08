# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BHOST ?= debian12

.PHONY: all
all:
	@echo
	@sed -n -e '/# Build libmraa/,/```$$/{/```/!p}' README.md
	@echo

include ../makefiles/gitlabci.mk
