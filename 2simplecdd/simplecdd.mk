# ---------------------------------------------------------------------------- #
## \file simplecdd.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = $(shell basename `readlink -f .`)
BUILDCD = build-simple-cdd --conf simple-cdd.conf --dvd --logfile /tmp/scdd.log
DATATMP = $(HOME)/data/install-build
DESTDIR = $(DATATMP)/$(shell basename $(shell pwd))
ifeq "$(LPKG)" ""
 ERROR="error: LKPG is not set\n"
endif

.SUFFIXES:

.PHONY: amd64-list
amd64-list: check-lpkg\
 amd64/simple-cdd.conf\
 amd64/profiles/amd64.packages\
 amd64/profiles/amd64.postinst

.PHONY: i386-list
i386-list: check-lpkg\
 i386/simple-cdd.conf\
 i386/profiles/i386.packages\
 i386/profiles/i386.postinst

.PHONY: check-lpkg
check-lpkg:
	@printf $(ERROR)"" >&2
	@test -z '$(ERROR)'

define add-extra-package
	(test -f "../$(LPKG)/build/"$2"_1.0_all.deb" &&\
	 echo $2 >>$1) || echo "warn: "$2"_1.0_all.deb not found"
endef

define add-extra-packages
	@echo task-lxde-desktop >>$1
	@echo openbox-lxde-session >>$1
	@echo perl-openssl-defaults >>$1
	@echo dbus-x11 >>$1
	@echo libdebian-installer4 >>$1
	@for i in `cat ../$(LPKG)/build/list.txt`; do\
	 $(call add-extra-package,$1,$$i); done
endef

amd64/simple-cdd.conf i386/simple-cdd.conf: simple-cdd.conf
	@cat $< |\
	 sed "s/LPKG/$(LPKG)/" |\
	 sed "s#DESTDIR#$(DESTDIR)#" |\
	 cat >$@

amd64/profiles/amd64.packages: list.txt ../$(LPKG)/build/list.txt
	@cat $< |\
	 sed '/:i386/D' |\
	 sed 's/ *#.*//' |\
	 sed '/^$$/D' |\
	 sed 's/:amd64//' |\
	 cat >$@
	$(call add-extra-packages,$@)

i386/profiles/i386.packages: list.txt ../$(LPKG)/build/list.txt
	@cat $< |\
	 sed 's/:i386//' |\
	 sed 's/libc6-i386//' |\
	 sed 's/ *#.*//' |\
	 sed '/^$$/D' |\
	 sed '/amd64/D' |\
	 cat >$@
	$(call add-extra-packages,$@)

amd64/profiles/amd64.postinst i386/profiles/i386.postinst: common.postinst
	@cat $< |\
	 sed "s/LPKG/$(LPKG)/" |\
	 cat >$@
	@chmod 755 $@

.PHONY: amd64 i386
amd64 i386:
	@mkdir -p $(DESTDIR)
	@cd $@ &&\
	 rsync -a -L -i profiles/ $(DESTDIR)/profiles/ &&\
	 $(BUILDCD) || (echo "logfile = /tmp/scdd.log" && false)

.PHONY: clean
clean:
	@$(RM)\
	 amd64/simple-cdd.conf\
	 amd64/profiles/amd64.packages\
	 amd64/profiles/amd64.postinst\
	 i386/simple-cdd.conf\
	 i386/profiles/i386.packages\
	 i386/profiles/i386.postinst\
	 *~
