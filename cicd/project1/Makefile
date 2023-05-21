# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
gitlabci = gitlabci-local -c gitlab-ci.yml -H

.SUFFIXES:

.PHONY: all clean
all clean: build/Makefile
	@cd build && make --no-print-directory -j4 $@

build/Makefile:
	@mkdir -p build && cd build && cmake ..

.PHONY: build install
build install:
	@$(gitlabci) $@

.PHONY: tests package
tests package: all
	@$(gitlabci) $@
