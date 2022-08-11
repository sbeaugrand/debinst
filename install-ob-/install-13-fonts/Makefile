# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
SUBDIRS = \
noeuds \
runes \

.PHONY: $(SUBDIRS)

.SUFFIXES:

.PHONY: all
all:
	@for dir in $(SUBDIRS); do \
		$(MAKE) --no-print-directory -C $$dir all; \
	done

.PHONY: install
install:
	@for dir in $(SUBDIRS); do \
		$(MAKE) --no-print-directory -C $$dir install; \
	done

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
