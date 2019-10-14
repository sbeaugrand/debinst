# ---------------------------------------------------------------------------- #
## \file simplecdd.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = $(shell basename `readlink -f .`)
BUILDCD = build-simple-cdd --conf simple-cdd.conf --dvd --logfile /tmp/scdd.log
DATATMP = $(HOME)/data/install-build

.SUFFIXES:

.PHONY: amd64-list
amd64-list: amd64/profiles/amd64.packages

.PHONY: i386-list
i386-list: i386/profiles/i386.packages

define add-extra-package
	(test -f "$(LPKG)"$2"_1.0_all.deb" &&\
	 echo $2 >>$1) || echo "warn: "$2"_1.0_all.deb not found"
endef

define add-extra-packages
	@echo task-lxde-desktop >>$1
	@echo openbox-lxde-session >>$1
	@echo perl-openssl-defaults >>$1
	@echo dbus-x11 >>$1
	@echo libdebian-installer4 >>$1
	@for i in `cat $(LPKG)/list.txt`; do $(call add-extra-package,$1,$$i); done
endef
#@echo libreoffice-style-galaxy >>$1

amd64/profiles/amd64.packages: list.txt $(LPKG)/list.txt $(MAKEFILE_LIST) FORCE
	@cat $< |\
	 sed '/:i386/D' |\
	 sed '/wine/D' |\
	 sed 's/ *#.*//' |\
	 sed '/^$$/D' |\
	 cat >$@
	$(call add-extra-packages,$@)

i386/profiles/i386.packages: list.txt $(LPKG)/list.txt $(MAKEFILE_LIST) FORCE
	@cat $< |\
	 sed 's/:i386//' |\
	 sed 's/libc6-i386//' |\
	 sed 's/ *#.*//' |\
	 sed '/^$$/D' |\
	 cat >$@
	$(call add-extra-packages,$@)

.PHONY: amd64 i386
amd64 i386:
	@mkdir -p $(DATATMP)/simple-cdd-$@
	@cd $@ &&\
	 rsync -a -L -i profiles/ $(DATATMP)/simple-cdd-$@/profiles/ &&\
	 $(BUILDCD)

.PHONY: clean
clean:
	@$(RM) *~ amd64/profiles/amd64.packages i386/profiles/i386.packages

FORCE:
