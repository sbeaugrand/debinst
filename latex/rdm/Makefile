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

.PHONY: $(SUBDIRS)

.SUFFIXES:

.PHONY: all
all:
	@for dir in $(SUBDIRS); do \
		$(MAKE) --no-print-directory -C $$dir all; \
		files="$$files $$dir/$$dir.pdf"; \
	done && \
	pdfjam $$files -o $(PROJECT).pdf

.PHONY: clean
clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) --no-print-directory -C $$dir clean; \
	done

.PHONY: mrproper
mrproper:
	@for dir in $(SUBDIRS); do \
		$(MAKE) --no-print-directory -C $$dir mrproper; \
	done

include $(PROROOT)/makefiles/tar.mk
