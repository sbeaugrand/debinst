# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
PROJECT = dokuwiki
PROPATH = wiki
DIR = /usr/share/dokuwiki/data/pages
CFG = /usr/share/dokuwiki/conf
DST = pi@rpi
RSYNC = rsync -ti --checksum --rsync-path="sudo rsync"

.SUFFIXES:

.PHONY: all
all:
	@echo "Usage:"
	@echo "  make install"
	@echo "  make { rdiff | rsync | rauth }"

.PHONY: install
install:
	@$(PROROOT)/../0install.sh install-op-$(PROJECT).sh

pages-pr-:
	@mkdir $@

.PHONY: rdiff
rdiff: pages-pr-
	@ssh $(DST) 'sudo tar cP\
	 --exclude=playground --exclude=wiki\
	 $(DIR) $(CFG)/users.auth.php' |\
	 tar xf - -C /tmp/ --transform='s,/usr/share/,,'
	@colordiff -u -r pages-pr- /tmp/dokuwiki/data/pages; true
	@colordiff -u users-pr-auth.php /tmp/dokuwiki/conf/users.auth.php; true
	@$(RM) -r /tmp/dokuwiki

.PHONY: rsync
rsync: pages-pr-
	@$(RSYNC) -r -f '- playground' -f '- wiki'\
	 $(DST):$(DIR)/ pages-pr-/

.PHONY: rauth
rauth:
	@$(RSYNC) $(DST):$(CFG)/users.auth.php users-pr-auth.php

include ${PROROOT}/makefiles/tar.mk
