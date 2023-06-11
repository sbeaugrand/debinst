# ---------------------------------------------------------------------------- #
## \file cmake.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BUILD ?= Debug

.PHONY: all clean
all clean: build/Makefile
	@cd build && make --no-print-directory -j4 $@

build/Makefile:
	@mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=$(BUILD)

.PHONY: cppcheck
cppcheck:
	@eval cppcheck -q --enable=all\
	 `test -f cppcheck.supp && echo --suppressions-list=cppcheck.supp`\
	 --template='{id}:{file}:{line}\ \({severity}\)\ {message}'\
	 -i build\
	 --suppress=missingIncludeSystem\
	 $(CPPCHECKINC) .
