# ---------------------------------------------------------------------------- #
## \file cmake.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note # CMAKE_OPT example for cross compile without sysroot :
##       ifeq (xc,$(findstring $(MAKECMDGOALS),xc))
##         XC = aarch64-linux-gnu
##         CMAKE_OPT = -DCMAKE_CXX_COMPILER=$(XC)-g++
##         QEMU_LD_PREFIX = /usr/aarch64-linux-gnu
##       endif
##       # Package without sysroot :
##       .PHONY: xp
##       xp:
##          @export XC=$(XC) &&\
##           DEB_BUILD_OPTIONS=crossbuildcanrunhostbinaries\
##           dpkg-buildpackage --no-sign -aarch64
# ---------------------------------------------------------------------------- #
BUILD ?= Debug

.PHONY: all clean
all clean: build/Makefile
	@cd build && make --no-print-directory -j`nproc` $@

.PHONY: xc
xc: build-$(XC)/Makefile
	@cd build-$(XC) &&\
	 export QEMU_LD_PREFIX=$(QEMU_LD_PREFIX) &&\
	 make --no-print-directory -j`nproc`

%/Makefile:
	@mkdir -p `dirname $@` &&\
	 cd `dirname $@` && cmake .. -DCMAKE_BUILD_TYPE=$(BUILD) $(CMAKE_OPT)

.PHONY: cppcheck
cppcheck:
	@eval cppcheck -q --enable=all\
	 `test -f cppcheck.supp && echo --suppressions-list=cppcheck.supp`\
	 --template='{id}:{file}:{line}\ \({severity}\)\ {message}'\
	 -i build -i build-*\
	 --suppress=missingIncludeSystem\
	 $(CPPCHECKINC) .

.PHONY: FORCE
FORCE:
