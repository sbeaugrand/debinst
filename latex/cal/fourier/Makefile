# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
N ?= 1
YEAR ?= $(shell date +%Y)
BDIR ?= ../build
include ../config.mk
-include ../config-pr-symlink.mk

FIRST = $(YEAR)
YEARS = $(shell echo | awk '{\
 for (i = $(FIRST); i < $(FIRST) + $(N); ++i)\
     printf i" ";\
 }')
MLIST0 = $(addsuffix -0.txt,$(addprefix $(BDIR)/jmeeus,$(YEARS)))
MLIST1 = $(addsuffix -1.txt,$(addprefix $(BDIR)/jmeeus,$(YEARS)))
MLIST2 = $(addsuffix -2.txt,$(addprefix $(BDIR)/jmeeus,$(YEARS)))
IYEARS = $(FIRST)-$(lastword $(YEARS))

.PHONY: help
help:
	@echo
	@echo "make dmax -j3"
	@echo "make plot"
	@echo "make test"
	@echo "make dmax -j3 N=4"
	@echo "make dmax -j3 N=32"
	@echo "make fft  -j3 N=4"
	@echo "make coeffs"
	@echo

.PHONY: dmax
dmax: dmax1 dmax0 dmax2
dmax0: $(BDIR)/jmeeus$(IYEARS)-0.txt $(BDIR)/result$(IYEARS)-0.txt
	@diff -y -W28 --suppress-common-lines $^ | ./dmax.awk
dmax1: $(BDIR)/jmeeus$(IYEARS)-1.txt $(BDIR)/result$(IYEARS)-1.txt
	@diff -y -W28 --suppress-common-lines $^ | ./dmax.awk
dmax2: $(BDIR)/jmeeus$(IYEARS)-2.txt $(BDIR)/result$(IYEARS)-2.txt
	@diff -y -W28 --suppress-common-lines $^ | ./dmax.awk

$(BDIR)/jmeeus$(IYEARS)-0.txt: $(MLIST0)
	@cat $^ | awk '{ print NR" "$$0 }' >$@
$(BDIR)/jmeeus$(IYEARS)-1.txt: $(MLIST1)
	@cat $^ | awk '{ print NR" "$$0 }' >$@
$(BDIR)/jmeeus$(IYEARS)-2.txt: $(MLIST2)
	@cat $^ | awk '{ print NR" "$$0 }' >$@

$(BDIR)/jmeeus%.txt: jmeeus.sh $(BDIR)/sun
	@./$< $(LAT) $(LON)\
	 `echo $@ | sed 's/.*\([0-9]\{4\}\).*/\1/'`\
	 $(H0)\
	 s`echo $@ | sed 's/.*-\([0-2]\)\..*/\1/'`\
	 >$@

$(BDIR)/sun: ../sun.c ../algos.c ../algos.h
	@cd .. && make --no-print-directory build
	@cd .. && make --no-print-directory build/sun

$(BDIR)/result%-0.txt: $(BDIR)/coeffs%-0.txt result.awk
	@cat $< | ./result.awk\
	 -v n=`cat $(BDIR)/jmeeus$(IYEARS)-0.txt | wc -l` >$@
$(BDIR)/result%-1.txt: $(BDIR)/coeffs%-1.txt result.awk
	@cat $< | ./result.awk\
	 -v n=`cat $(BDIR)/jmeeus$(IYEARS)-1.txt | wc -l` >$@
$(BDIR)/result%-2.txt: $(BDIR)/coeffs%-2.txt result.awk
	@cat $< | ./result.awk\
	 -v n=`cat $(BDIR)/jmeeus$(IYEARS)-2.txt | wc -l` >$@

$(BDIR)/coeffs%.txt: $(BDIR)/jmeeus%.txt coeffs.py
	@./coeffs.py $< >$@

.PHONY: plot
plot: $(BDIR)/jmeeus$(IYEARS)-2.txt $(BDIR)/result$(IYEARS)-2.txt
	./plot.py $^

.PHONY: fft
fft: $(BDIR)/jmeeus$(IYEARS)-2.txt
	./fft.py $<

.PHONY: test
test: test1 test0 test2
test0: $(BDIR)/coeffs$(IYEARS)-0.txt result.py
	@cat $< | ./result.py
test1: $(BDIR)/coeffs$(IYEARS)-1.txt result.py
	@cat $< | ./result.py
test2: $(BDIR)/coeffs$(IYEARS)-2.txt result.py
	@cat $< | ./result.py

.PHONY: coeffs
coeffs:
	@grep -H . ../build/coeffs* |\
	 sed 's/.*coeffs\(.*\)-\([0-2]\)\.txt/\2:\1/' | sort

.PHONY: clean
clean:
	@$(RM) $(BDIR)/coeffs* $(BDIR)/result* *~

.PHONY: mrproper
mrproper: clean
	@$(RM) $(BDIR)/jmeeus*
