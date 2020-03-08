# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = recettes
BROWSER = firefox

.SUFFIXES:

.PHONY: all
all: http

include ../../makefiles/http.mk

.PHONY: clean
clean:
	@$(RM) *~

.PHONY: tar
tar:
	@cd .. && tar cvzf $(PROJECT).tgz \
	--exclude=*~ \
	--exclude=.*.swp \
	$(PROJECT)
