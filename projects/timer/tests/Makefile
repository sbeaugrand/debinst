# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../../..
CFLAGS += -I..

.PHONY: test
test: build build/test-timer2313 build/test-timer45
	@build/test-timer2313 4000000 0 5000 | tee build/test.out
	@build/test-timer2313 4000000 1 200000 | tee -a build/test.out
	@build/test-timer45 4000000 0 5000 | tee -a build/test.out
	@build/test-timer45 4000000 1 200000 | tee -a build/test.out
	@build/test-timer45 4000000 1 347 | tee -a build/test.out
	@build/test-timer45 4000000 1 348 | tee -a build/test.out
	@diff test.ref build/test.out && echo OK

build/test-timer%: build/test-timer%.o
	$(CC) $^ -o $@

include ${PROROOT}/makefiles/ccpp.mk
