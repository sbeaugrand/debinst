# ---------------------------------------------------------------------------- #
## \file gitlabci.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
HOST ?= lubuntu
-include ../$(HOST)/host.mk

PROJECT ?= $(shell basename `readlink -f .`)
IMAGE ?= ubuntu:22.10
BUILD ?= Debug
URI ?= exemple@ip
SSH ?= vagrant ssh -c
USERPATH ?= /vagrant/.vagrant
BHOST ?= $(HOST)
XC ?= aarch64-linux-gnu
XCVER ?= 12
ifneq ($(SUDOPASS),)
 OPTS = -e SUDOPASS=$(SUDOPASS)
endif

ifeq ($(CMAKE),)
 NCMAKE = cmake .. -DCMAKE_BUILD_TYPE=$(BUILD)
else ifeq ($(CMAKE),qmake)
 NCMAKE = qmake ../$(PROJECT).pro
else
 NCMAKE = $(CMAKE)
endif

gitlabci = ~/.local/bin/gitlabci-local\
 -e HOST=$(HOST)\
 -e IMAGE=$(IMAGE)\
 -e BUILD=$(BUILD)\
 -e CMAKE="$(NCMAKE)"\
 -e URI=$(URI)\
 -e SSH="$(SSH)"\
 -e USERPATH=$(USERPATH)\
 -e BHOST=$(BHOST)\
 -e XC=$(XC)\
 -e XCVER=$(XCVER)\
 $(OPTS)\
 -c gitlab-ci.yml
propath = $(shell basename `readlink -f .`)

.SUFFIXES:

.PHONY: \
build test package install rbuild rtest rpackage rinstall rdeploy stest
build test package install rbuild rtest rpackage rinstall rdeploy stest:
	@$(gitlabci) -H -R -p $@

.PHONY: \
xbuild xdeploy xtest
xbuild xdeploy xtest:
	@$(gitlabci) -H -R -p $@

.PHONY: deploy
deploy:
	@$(gitlabci) -E docker $@

test%:
	@$(gitlabci) -H -R $@

.PHONY: pipeline
pipeline: test rbuild rtest rpackage rdeploy stest

.PHONY: xpipeline
xpipeline: test xbuild xdeploy xtest

.PHONY: tar
tar:
	@cd .. && tar cvzf $(propath).tgz\
	 --exclude=*~\
	 --exclude=.*.swp\
	 --exclude=build\
	 makefiles\
	 $(propath)
