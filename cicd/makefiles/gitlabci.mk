# ---------------------------------------------------------------------------- #
## \file gitlabci.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
gitlabci = gitlabci-local -c gitlab-ci.yml
propath = $(shell basename `readlink -f .`)

.SUFFIXES:

.PHONY: build install remote
build install remote:
	@$(gitlabci) -H $@

.PHONY: tests package
tests package: all
	@$(gitlabci) -H $@

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
