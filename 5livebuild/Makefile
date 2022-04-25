# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = $(shell basename `readlink -f .`)
CODENAME = $(shell lsb_release -sc)
MIRROR = $(HOME)/data/install-build/simplecdd-op-1amd64/tmp/mirror
CHROOTDIR = build/config/includes.chroot
SKELDIR = $(CHROOTDIR)/etc/skel
RSYNC = rsync -aO -i --delete --delete-excluded
DST = build/live-image-amd64.hybrid.iso

.SUFFIXES:

.PHONY: all
all:

-include user-config-pr-symlink.mk

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
	 --iso-volume "Debian $(CODENAME) `date +%Y%m%d-%H:%M`"\
	 --archive-areas "main contrib non-free"\
	 --bootappend-live "boot=live persistence components locales=fr_FR.UTF-8 keyboard-layouts=fr timezone=Europe/Paris"\
	 --apt-recommends false\
	 --update false\
	 --security false\
	 --cache-indices true\
	 --mirror-bootstrap http://localhost:8000/\
	 --parent-mirror-binary http://localhost:8000/\
	 --mirror-binary http://localhost:8000/\
	 --apt-secure false

.PHONY: sync
sync: list skel

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
 $(SKELDIR)/.xscreensaver\
 $(SKELDIR)/.local/share/applications/screen.desktop\
 $(SKELDIR)/.local/bin\
 $(SKELDIR)/.local/lib/codecs\

$(SKELDIR)/install: FORCE
	@mkdir -p $@
	@$(RSYNC)\
	 --include=repo/*.tgz\
	 --exclude-from=../.gitignore\
	 --exclude-from=../homepage/.gitignore\
	 --exclude=.git\
	 ~/install/ $@/
$(SKELDIR)/.%: $(HOME)/.%
	@$(RSYNC) $< $@
$(SKELDIR)/.bashrc: $(HOME)/.bashrc
	@sed "s@$(HOME)@/home/user@g" $< >$@
$(SKELDIR)/.mplayer/config: $(HOME)/.mplayer/config
	@mkdir -p $(SKELDIR)/.mplayer
	@$(RSYNC) $< $@
$(SKELDIR)/.xscreensaver:
	@echo "mode: one" >$@
	@echo "selected: 21" >>$@
$(SKELDIR)/.local/share/applications/screen.desktop: $(HOME)/.local/share/applications/screen.desktop
	@mkdir -p $(SKELDIR)/.local/share/applications
	@sed "s@$(HOME)@/home/user@g" $< >$@

$(SKELDIR)/.local/bin: FORCE
	@mkdir -p $@
	@$(RSYNC) $(HOME)/.local/bin/ $@/

$(SKELDIR)/.local/lib/codecs: FORCE
	@mkdir -p $@
	@$(RSYNC) $(HOME)/.local/lib/codecs/ $@/

.PHONY: aptsources
aptsources: build/chroot/etc/apt/sources.list.d/debian.list build/chroot/etc/apt/sources.list
build/chroot/etc/apt/sources.list.d/debian.list: FORCE
	@echo "deb http://httpredir.debian.org/debian $(CODENAME) main contrib non-free" | sudo tee $@ >/dev/null
	@echo "deb http://httpredir.debian.org/debian/ $(CODENAME)-updates main contrib non-free" | sudo tee -a $@ >/dev/null
build/chroot/etc/apt/sources.list: FORCE
	@sudo sed -i 's/^/#/' $@

.PHONY: clean
clean:
	@cd build && sudo lb clean

.PHONY: installer
installer:
	@cd build && sudo lb bootstrap
	@cd build && sudo lb chroot
	@cd build && sudo lb installer

.PHONY: binary
binary: $(DST)
$(DST): FORCE
	@cd build && sudo lb binary
	@stat -c '%s' $@ | awk '{ printf "%.1f GB\n",$$0 / 1e9 }'

.PHONY: FORCE
FORCE:
