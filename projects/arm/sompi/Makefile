# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
remote = shutter-pr-
contrl = sudo PYTHONPATH=. ./SomPi/controller.py $(remote)

.SUFFIXES:

.PHONY: all
all:
	@echo "Usage: make { register | open | close | stop }"

.PHONY: register open close stop
register open close stop:
	@$(contrl) $@
