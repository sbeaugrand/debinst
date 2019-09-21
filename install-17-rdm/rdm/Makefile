# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
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
	pdfjam $$files -o rdm.pdf

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

.PHONY: tar
tar:
	@cd .. && \
	tar cvzf rdm.tgz \
	--exclude=*~ \
	--exclude=.*.swp \
	--exclude=build \
	--exclude=*.pdf \
	rdm
