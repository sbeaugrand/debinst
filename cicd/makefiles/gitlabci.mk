# ---------------------------------------------------------------------------- #
## \file gitlabci.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT ?= $(shell basename `readlink -f .`)
VM ?= lubuntu
IMAGE ?= ubuntu:22.10
BUILD ?= Debug
ifeq ($(CMAKE),)
 NCMAKE = cmake .. -DCMAKE_BUILD_TYPE=$(BUILD)
else ifeq ($(CMAKE),qmake)
 NCMAKE = qmake ../$(PROJECT).pro
else
 NCMAKE = $(CMAKE)
endif

gitlabci = gitlabci-local\
 -e VM=$(VM)\
 -e IMAGE=$(IMAGE)\
 -e BUILD=$(BUILD)\
 -e CMAKE="$(NCMAKE)"\
 -c gitlab-ci.yml
propath = $(shell basename `readlink -f .`)

.SUFFIXES:

.PHONY: build install rbuild rinstall
build install rbuild rinstall:
	@$(gitlabci) -H -R -p $@

.PHONY: test package rpackage
test package rpackage: all
	@$(gitlabci) -H -R $@

.PHONY: deploy
deploy:
	@$(gitlabci) -E docker $@

.PHONY: tar
tar:
	@cd .. && tar cvzf $(propath).tgz\
	 --exclude=*~\
	 --exclude=.*.swp\
	 --exclude=build\
	 makefiles\
	 $(propath)
