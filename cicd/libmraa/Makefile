# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BHOST ?= debian12

.PHONY: all
all:
	@echo "Usage: make build"
	@echo "       make package"
	@echo "       cd ../hosts/debian12 && make up && cd -"
	@echo "       make rbuild"
	@echo "       make rpackage"
	@echo "       make rxpackage [OPTS='-e ARCH=armhf']"

include ../makefiles/gitlabci.mk
