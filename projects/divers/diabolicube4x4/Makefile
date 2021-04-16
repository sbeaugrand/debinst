# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
include ${PROROOT}/makefiles/pro.mk

.PHONY: all
all: $(PROJECT)

.PHONY: $(PROJECT)
$(PROJECT): build build/$(PROJECT)
build/$(PROJECT): build/$(PROJECT).o
	$(CC) $^ -o $@

.PHONY: test
test:
	build/$(PROJECT) | tee build/$(PROJECT).log

WARNINGS = -Wall -Wextra -O3 -D_FORTIFY_SOURCE=2
include $(PROROOT)/makefiles/ccpp.mk

include $(PROROOT)/makefiles/tar.mk
