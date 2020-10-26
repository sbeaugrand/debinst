# ---------------------------------------------------------------------------- #
## \file tar.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/tar.mk
TARGETS += "| tar | dist"
ifneq ($(PROPATH),)
 TPREFIX = $(subst /,-,$(PROPATH))-
 PPREFIX = $(PROPATH)/
endif
TEXCLUDE = *~ *.d *.o *.so *.a *.out\
 *.bck *-bak *-cache.* *-rescue.* .*.swp build portrait-*.pdf *.ps
ifeq ($(MAKECMDGOALS),dist)
 TEXCLUDE += *-pr-* *.pdf
endif
TEXCLUDE := $(addprefix --exclude=,$(TEXCLUDE))
TARROOT ?= $(PROROOT)

.PHONY: tar dist
tar dist:
	@cd $(TARROOT) && \
	ls -d $(PPREFIX)$(PROJECT) $(TARDEPEND) | sort -u | \
	tar cvzf $(TPREFIX)$(PROJECT).tgz $(TEXCLUDE) -T-
