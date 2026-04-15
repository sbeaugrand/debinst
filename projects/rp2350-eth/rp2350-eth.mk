# ---------------------------------------------------------------------------- #
## \file rp2350-eth.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT ?= ..
DOC = $(PROROOT)/rp2350-eth.md

.SUFFIXES:

define print-help
 sed -n -e '/# $1$$/,/``$$/{/^ *``/!p}' $(DOC) | grep --color -C99 '^#\+ .*'
endef

.PHONY: help
help:
	@echo
	@$(call print-help,Pico-sdk)
	@echo
	@$(call print-help,Picotool)
	@echo
	@$(call print-help,Project)
	@echo
