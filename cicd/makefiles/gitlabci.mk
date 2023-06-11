# ---------------------------------------------------------------------------- #
## \file gitlabci.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
VM ?= lubuntu
BUILD ?= Debug

gitlabci = gitlabci-local -c gitlab-ci.yml -e VM=$(VM) -e BUILD=$(BUILD)
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
