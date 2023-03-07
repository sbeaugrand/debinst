# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = rdm
PROROOT = ..
SUBDIRS = \
rdmpafsym \
rdmpaf \

PDFS = $(join $(addsuffix /,$(SUBDIRS)),$(addsuffix .pdf,$(SUBDIRS)))
define submake
 for dir in $(SUBDIRS); do $(MAKE) -C $$dir $1; done
endef

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf
$(PROJECT).pdf: $(PDFS)
	@$(call submake,all)
	@pdfjam -q -o $@ $(PDFS)

$(PDFS):

.PHONY: clean
clean:
	@$(call submake,clean)

.PHONY: mrproper
mrproper:
	@$(call submake,mrproper)
	@$(RM) $(PROJECT).pdf

include $(PROROOT)/makefiles/tar.mk
