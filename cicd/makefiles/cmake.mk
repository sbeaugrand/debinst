# ---------------------------------------------------------------------------- #
## \file cmake.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.PHONY: all clean
all clean: build/Makefile
	@cd build && make --no-print-directory -j4 $@

build/Makefile:
	@mkdir -p build && cd build && cmake ..
