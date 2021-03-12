# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.SUFFIXES:

.PHONY: test
test:
	@./stub.py &
	@sleep 1
	@cat stub.nc | ./gcodesender.py

.PHONY: itest
itest:
	@./stub.py &
	@sleep 1
	@./gcodesender.py -i
