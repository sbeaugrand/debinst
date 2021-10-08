# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
PROJECT = dokuwiki
PROPATH = wiki
DIR = /var/lib/dokuwiki/data

.SUFFIXES:

.PHONY: all
all:
	@echo "Usage:"
	@echo "  make install"
	@echo "  sudo make { diff | save }"
	@echo "  make rsync"

.PHONY: install
install:
	@$(PROROOT)/../0install.sh install-op-$(PROJECT).sh

pages-pr-:
	@mkdir $@

.PHONY: diff
diff: pages-pr-
	@diff -r -x playground -x wiki pages-pr-/ $(DIR)/pages/; true

.PHONY: save
save: pages-pr-
	@cp -uv $(DIR)/pages/*.txt pages-pr-/
	@chown $(SUDO_USER).$(SUDO_USER) pages-pr-/*

.PHONY: rsync
rsync:
	@rsync -rti --checksum --delete --rsync-path="sudo rsync"\
	 -f '- playground' -f '- wiki'\
	 pi@rpi:/var/lib/dokuwiki/data/pages/ pages-pr-/

include ${PROROOT}/makefiles/tar.mk
