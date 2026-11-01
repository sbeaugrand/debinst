# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
NYEAR ?= 1
YEAR ?= $(shell date +%Y)
BDIR ?= ../build
include ../config.mk
-include ../config-pr-symlink.mk
DIFF = diff -y -W28 --suppress-common-lines
NDAY = $(shell echo 365*$(NYEAR) | bc)

.PHONY: help
help:
	@echo
	@echo make dmax
	@echo make plot
	@echo make test
	@echo make mrproper
	@echo make dmax -j3 NYEAR=4
	@echo make mrproper
	@echo make dmax -j3 NYEAR=32
	@echo

.PHONY: dmax
dmax: dmax1 dmax0 dmax2
dmax0: $(BDIR)/jmeeus$(YEAR)-0.txt $(BDIR)/result$(YEAR)-0.txt
	@head -n $(NDAY) $< | $(DIFF) - $(BDIR)/result$(YEAR)-0.txt | ./dmax.awk
dmax1: $(BDIR)/jmeeus$(YEAR)-1.txt $(BDIR)/result$(YEAR)-1.txt
	@head -n $(NDAY) $< | $(DIFF) - $(BDIR)/result$(YEAR)-1.txt | ./dmax.awk
dmax2: $(BDIR)/jmeeus$(YEAR)-2.txt $(BDIR)/result$(YEAR)-2.txt
	@head -n $(NDAY) $< | $(DIFF) - $(BDIR)/result$(YEAR)-2.txt | ./dmax.awk

$(BDIR)/jmeeus$(YEAR)-0.txt: jmeeus.sh $(BDIR)/sun
	@./$< $(LAT) $(LON) $(YEAR) s0 $(NYEAR) >$@
$(BDIR)/jmeeus$(YEAR)-1.txt: jmeeus.sh $(BDIR)/sun
	@./$< $(LAT) $(LON) $(YEAR) s1 $(NYEAR) >$@
$(BDIR)/jmeeus$(YEAR)-2.txt: jmeeus.sh $(BDIR)/sun
	@./$< $(LAT) $(LON) $(YEAR) s2 $(NYEAR) >$@

$(BDIR)/sun: ../sun.c ../algos.c ../algos.h
	@cd .. && make --no-print-directory build
	@cd .. && make --no-print-directory build/sun

$(BDIR)/result%.txt: $(BDIR)/coeffs%.txt result.awk
	@cat $< | ./result.awk -v NYEAR=$(NYEAR) >$@

$(BDIR)/coeffs%.txt: $(BDIR)/jmeeus%.txt coeffs.py
	@./coeffs.py $< >$@

.PHONY: plot
plot: $(BDIR)/jmeeus$(YEAR)-2.txt $(BDIR)/result$(YEAR)-2.txt
	./plot.py $^

.PHONY: test
test: test1 test0 test2
test0: $(BDIR)/coeffs$(YEAR)-0.txt result.py
	@cat $< | ./result.py
test1: $(BDIR)/coeffs$(YEAR)-1.txt result.py
	@cat $< | ./result.py
test2: $(BDIR)/coeffs$(YEAR)-2.txt result.py
	@cat $< | ./result.py

.PHONY: clean
clean:
	@$(RM) $(BDIR)/coeffs* $(BDIR)/result* *~

.PHONY: mrproper
mrproper: clean
	@$(RM) $(BDIR)/jmeeus*
