# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = $(shell basename `readlink -f .`)
CODENAME = buster
MIRROR = $(HOME)/data/install-build/simplecdd-op-1amd64/tmp/mirror
CHROOTDIR = build/config/includes.chroot
SKELDIR = $(CHROOTDIR)/etc/skel
RSYNC = rsync --delete -aO -f '-s_build/***' -i

.SUFFIXES:

.PHONY: all
all:

.PHONY: mirror
mirror:\
 $(MIRROR)/dists/$(CODENAME)/main/Contents-amd64.gz\
 $(MIRROR)/dists/$(CODENAME)/contrib/Contents-amd64.gz\
 $(MIRROR)/dists/$(CODENAME)/non-free/Contents-amd64.gz
$(MIRROR)/dists/$(CODENAME)/%/Contents-amd64.gz:\
 $(MIRROR)/dists/$(CODENAME)/%/Contents-amd64
	@gzip -k -f $<
$(MIRROR)/dists/$(CODENAME)/main/Contents-amd64: FORCE
	cd $(MIRROR) && apt-ftparchive contents pool/main >$@
$(MIRROR)/dists/$(CODENAME)/contrib/Contents-amd64: FORCE
	cd $(MIRROR) && apt-ftparchive contents pool/contrib >$@
$(MIRROR)/dists/$(CODENAME)/non-free/Contents-amd64: FORCE
	cd $(MIRROR) && apt-ftparchive contents pool/non-free >$@

.PHONY: http
http:
	cd $(MIRROR) && python3 -m http.server

build:
	@mkdir $@

.PHONY: config
config: build
	@cd build && lb config\
	 --distribution $(CODENAME)\
	 --parent-distribution $(CODENAME)\
	 --parent-debian-installer-distribution $(CODENAME)\
	 --debian-installer-distribution $(CODENAME)\
	 --iso-volume "Debian buster `date +%Y%m%d-%H:%M`"\
	 --archive-areas "main contrib non-free"\
	 --bootappend-live "boot=live components locales=fr_FR.UTF-8 keyboard-layouts=fr"\
	 --apt-recommends false\
	 --update false\
	 --security false\
	 --cache-indices true\
	 --mirror-bootstrap http://localhost:8000/\
	 --parent-mirror-binary http://localhost:8000/\
	 --mirror-binary http://localhost:8000/\
	 --apt-secure false

.PHONY: sync
sync: list skel local-bin codecs

.PHONY: list
list:\
 build/config/package-lists/amd64.list\
 build/config/package-lists/base.list
build/config/package-lists/amd64.list: ../simplecdd-op-1amd64/list.txt
	@sed 's/#.*//' $< |\
	 grep -v ":i386" |\
	 grep -v "wine" |\
	 cat >$@
build/config/package-lists/base.list:
	@cat /dev/null >$@
	@echo task-lxde-desktop >>$@
	@echo openbox-lxde-session >>$@
	@echo perl-openssl-defaults >>$@
	@echo dbus-x11 >>$@
	@echo libdebian-installer4 >>$@

.PHONY: skel
skel: $(SKELDIR)/install\
 $(SKELDIR)/.bashrc\
 $(SKELDIR)/.screenrc\
 $(SKELDIR)/.vimrc\
 $(SKELDIR)/.mplayer/config\
 $(SKELDIR)/.xscreensaver
$(SKELDIR)/install: FORCE
	@mkdir -p $@
	@$(RSYNC) ~/install/ $@/
$(SKELDIR)/.%: $(HOME)/.% FORCE
	@$(RSYNC) $< $@
$(SKELDIR)/.mplayer/config: $(HOME)/.mplayer/config
	@mkdir -p $(SKELDIR)/.mplayer
	@$(RSYNC) $< $@
$(SKELDIR)/.xscreensaver: FORCE
	@echo "mode: one" >$@
	@echo "selected: 21" >>$@

.PHONY: local-bin
local-bin: $(CHROOTDIR)/usr/local/bin
$(CHROOTDIR)/usr/local/bin: FORCE
	@mkdir -p $@
	@$(RSYNC) /usr/local/bin/ $@/

.PHONY: codecs
codecs: $(CHROOTDIR)/usr/lib/codecs
$(CHROOTDIR)/usr/lib/codecs: FORCE
	@mkdir -p $@
	@$(RSYNC) /usr/lib/codecs/ $@/

.PHONY: clean
clean:
	@cd build && sudo lb clean

.PHONY: lb-build
lb-build: build/live-image-amd64.hybrid.iso
build/live-image-amd64.hybrid.iso: FORCE
	@cd build && sudo lb build
	@stat -c '%s' $@ | awk '{ printf "%.1f GB\n",$$0 / 1e9 }'

.PHONY: FORCE
FORCE:
