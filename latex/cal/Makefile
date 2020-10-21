# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
YEAR = 2021
include config.mk
ifneq ($(MAKECMDGOALS),dist-cal)
 ifneq ($(MAKECMDGOALS),dist-cadran)
  -include config-pr-symlink.mk
 endif
endif
CFLAGS += -DWITH_EQUATION_OF_TIME
#CFLAGS += -DWITH_ALTITUDE

ifeq ($(idir),)
 REPO = $(HOME)/install/calendar
else
 REPO = $(idir)/../repo
endif
BDIR  = $(HOME)/data/install-build

.PHONY: all
all:
	@echo
	@echo -n "Usage: make { cal | cadran | testAlgos | testPaques | testSun "
	@echo -n $(TARGETS)
	@echo -n " | portrait-cal$(YEAR).pdf | portrait-cadran.pdf"
	@echo -n " | dist-clean | dist-cal | dist-cadran }"
	@echo " [WIDTH=61.0 HEIGHT=29.7 STRAIGHT_STYLUS_LENGTH=6.5]"
	@echo

LDFLAGS = -lm
PROROOT = ..
PROJECT = cal
include $(PROROOT)/makefiles/ccpp.mk

.PHONY: cal dist-cal
cal dist-cal: build cal$(YEAR).pdf

cal$(YEAR).pdf: cal.tex\
 build/sun build/moon\
 build/moonphase.mf build/calendar/calend0.tex\
 build/year.tex build/lat.tex build/lon.tex build/h0.tex build/vacances$(YEAR).tex
	cd build && TEXINPUTS="calendar:..:"\
	 pdflatex --halt-on-error --shell-escape ../cal.tex
	mv build/cal.pdf $@

build/moonphase.mf: $(REPO)/moonphase.mf
	@ln -sf $< $@

$(REPO)/moonphase.mf:
	@curl -o $@\
	 ftp://dante.ctan.org/tex-archive/fonts/moonphase/moonphase.mf

build/calendar/calend0.tex: $(REPO)/calendar.zip
	@unzip $< -d build
	@touch $@

$(REPO)/calendar.zip:
	@curl -o $@\
	 ftp://dante.ctan.org/tex-archive/macros/plain/contrib/calendar.zip

build/year.tex: $(MAKEFILE_LIST)
	@echo "\def\\\annee{$(YEAR)}" >$@

build/lat.tex: $(MAKEFILE_LIST)
	@echo "\def\latitude{$(LAT)}" >$@

build/lon.tex: $(MAKEFILE_LIST)
	@echo "\def\longitude{$(LON)}" >$@

build/h0.tex: $(MAKEFILE_LIST)
	@echo "\def\h0{$(H0)}" >$@

build/vacances$(YEAR).tex: vacances.sh $(MAKEFILE_LIST)
	$< $(YEAR) tex >$@

build/sun: build/algos.o build/sun.o
	$(LINK.c) $^ -o $@

build/moon: build/algos.o build/moon.o
	$(LINK.c) $^ -o $@

.PHONY: testAlgos
testAlgos: build build/testAlgos
	@build/testAlgos && echo OK

build/testAlgos: build/algos.o build/testAlgos.o
	$(LINK.c) $^ -o $@

.PHONY: testPaques
testPaques:
	testPaques.sh | diff -y --suppress-common-lines testPaquesDim.ref -
	cd build && TEXINPUTS="..:" pdflatex ../testPaques.tex | grep G= |\
	 diff -y --suppress-common-lines ../testPaquesLun.ref -
	cut -d ' ' -f 1 testPaquesLun.ref >build/lun.ref
	cat testPaquesDim.ref |\
	 awk 'BEGIN { FS = "-| " } { print $$2"/"$$1"/"$$3 }' |\
	 xargs -I {} date -d "{} +1 day" +%d-%m-%Y |\
	 diff -y --suppress-common-lines build/lun.ref -

.PHONY: testSun
testSun: build build/sun
	@build/sun `date +%Y-%m-%d` $(LAT) $(LON) $(H0)

.PHONY: cadran dist-cadran
cadran dist-cadran: build cadran.pdf

build/config.tex: $(MAKEFILE_LIST)
	@echo -n "\def\sousStylaire" >$@
	@echo "$(LAT) $(STRAIGHT_STYLUS_LENGTH)" |\
	 awk '{ a=$$1*3.14159/180; printf "{%f}\n",$$2*sin(a)/cos(a) }' >>$@
	@echo "\\\newlength{\width}" >>$@
	@echo "\setlength{\width}{$(WIDTH)cm}" >>$@
	@echo "\\\newlength{\height}" >>$@
	@echo "\setlength{\height}{$(HEIGHT)cm}" >>$@

build/%.dat: cadran.sh build/cadran
	cadran.sh $(YEAR)\
	 $(LAT) $(LON) $(STRAIGHT_STYLUS_LENGTH) $(GNOMONIC_DECLINATION) $@

build/cadran: build/algos.o build/cadran.o
	$(LINK.c) $^ -o $@

cadran.pdf: cadran.tex build/config.tex\
 build/hiv07.dat\
 build/ete07.dat\
 build/hiv07_5.dat\
 build/ete07_5.dat\
 build/hiv08.dat\
 build/ete08.dat\
 build/hiv08_5.dat\
 build/ete08_5.dat\
 build/hiv09.dat\
 build/ete09.dat\
 build/hiv09_5.dat\
 build/ete09_5.dat\
 build/hiv10.dat\
 build/ete10.dat\
 build/hiv10_5.dat\
 build/ete10_5.dat\
 build/hiv11.dat\
 build/ete11.dat\
 build/hiv11_5.dat\
 build/ete11_5.dat\
 build/hiv12.dat\
 build/ete12.dat\
 build/hiv12_5.dat\
 build/ete12_5.dat\
 build/hiv13.dat\
 build/ete13.dat\
 build/hiv13_5.dat\
 build/ete13_5.dat\
 build/hiv14.dat\
 build/ete14.dat\
 build/hiv14_5.dat\
 build/ete14_5.dat\
 build/hiv15.dat\
 build/ete15.dat\
 build/hiv15_5.dat\
 build/ete15_5.dat\
 build/hiv16.dat\
 build/ete16.dat\
 build/hiv16_5.dat\
 build/ete16_5.dat\
 build/hiv17.dat\
 build/ete17.dat
	cd build && pdflatex --halt-on-error ../cadran.tex
	mv build/$@ .

portrait-%.pdf: %.pdf
	pdf90 -q -o $@ $<

.PHONY: dist-clean
dist-clean:
	@$(RM) *.pdf build/*.tex build/*.dat

include $(PROROOT)/makefiles/tar.mk
