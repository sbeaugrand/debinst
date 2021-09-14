# ---------------------------------------------------------------------------- #
## \file livret.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/livret.mk

.PHONY: all
all: $(PROJECT).pdf

build:
	@mkdir $@

.PHONY: clean
clean:
	@$(RM) build/*.*

.PHONY: mrproper
mrproper: clean
	@rmdir build
	@$(RM) $(PROJECT).pdf

include $(PROROOT)/makefiles/pdf.mk
