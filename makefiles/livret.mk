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
	@$(RM) build/*.*; true

.PHONY: mrproper
mrproper: clean
	@test ! -d build || rmdir build
	@$(RM) $(PROJECT).pdf\
	 livret-$(PROJECT).pdf\
	 portrait-$(PROJECT).pdf\
	 extrait-$(PROJECT).pdf\
	 ; true

include $(PROROOT)/makefiles/pdf.mk
