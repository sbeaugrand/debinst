# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
gitlabci = gitlabci-local -c gitlab-ci.yml -H

.SUFFIXES:

.PHONY: all clean
all clean:
	@cd build && make --no-print-directory -j4 $@

.PHONY: build install
build install:
	@$(gitlabci) $@

.PHONY: tests package
tests package: all
	@$(gitlabci) $@
