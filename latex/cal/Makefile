# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
YEAR = 2023

# cal options
#MOON = build/moon-events build/moon-themes
MOON = build/moon-events

# sundial options
#CFLAGS += -DWITH_EQUATION_OF_TIME
CFLAGS += -DWITH_AZIMUT
#CFLAGS += -DWITH_DECLINATION

include config.mk
ifneq ($(MAKECMDGOALS),dist-cal)
 ifneq ($(MAKECMDGOALS),dist-cadran)
  -include config-pr-symlink.mk
 endif
endif

.PHONY: all
all:
	@echo
	@echo -n "Usage: make { cal | cadran | testAlgos | testPaques | testSun "
	@echo -n $(TARGETS)
	@echo -n " | portrait-cal$(YEAR).pdf | portrait-cadran.pdf"
	@echo -n " | dist-clean | dist-cal | dist-cadran }"
	@echo " [WIDTH=61.0 HEIGHT=29.7 STRAIGHT_STYLUS_LENGTH=6.5]"
	@echo

PROROOT = ..
include $(PROROOT)/makefiles/repo.mk
LDLIBS = -lm
include $(PROROOT)/makefiles/ccpp.mk

.PHONY: cal dist-cal
cal dist-cal: build cal$(YEAR).pdf

cal$(YEAR).pdf: cal.tex\
 build/sun $(MOON)\
 build/moonphase.mf build/calendar build/calendar/calend0.tex\
 build/year.tex build/lat.tex build/lon.tex build/h0.tex build/vacances$(YEAR).tex
	cd build && TEXINPUTS="calendar:..:"\
	 pdflatex --halt-on-error --shell-escape ../cal.tex
	mv build/cal.pdf $@

build/moonphase.mf: $(REPO)/moonphase.mf
	@ln -sf $< $@

$(REPO)/moonphase.mf:
	@curl -o $@\
	 http://dante.ctan.org/tex-archive/fonts/moonphase/moonphase.mf

build/calendar:
	@mkdir $@

build/calendar/calend0.tex: $(REPO)/calendar.zip
	@unzip $< -d build
	@touch $@

$(REPO)/calendar.zip:
	@curl -o $@\
	 http://dante.ctan.org/tex-archive/macros/plain/contrib/calendar.zip

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

build/%: build/%.o build/algos.o
	$(LINK.c) $^ $(LDLIBS) -o $@

.PHONY: azimut
azimut: build/azimut

.PHONY: testAlgos
testAlgos: build build/testAlgos
	@build/testAlgos && echo OK

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

.PHONY: testAzimut
testAzimut:
	@build/azimut 2021-06-21 48.44728 1.48749 7.66666 | diff testAzimut.ref -

.PHONY: cadran dist-cadran
cadran dist-cadran: build cadran.pdf

build/config.tex: $(MAKEFILE_LIST)
	@echo "\\\newlength{\sousStylaire}" >$@
	@echo -n "\setlength{\sousStylaire}" >>$@
	@echo "$(LAT) $(STRAIGHT_STYLUS_LENGTH)" |\
	 awk '{ a=$$1*3.14159/180; printf "{%fcm}\n",$$2*sin(a)/cos(a) }' >>$@
	@echo "\\\newlength{\width}" >>$@
	@echo "\setlength{\width}{$(WIDTH)cm}" >>$@
	@echo "\\\newlength{\height}" >>$@
	@echo "\setlength{\height}{$(HEIGHT)cm}" >>$@
	@echo "\\\newlength{\horizon}" >>$@
	@echo -n "\setlength{\horizon}" >>$@
	@echo "$(STYLUS_ANGLE) $(STRAIGHT_STYLUS_LENGTH)" |\
	 awk '{ a=(90-$$1)*3.14159/180; printf "{%fcm}\n",$$2*sin(a)/cos(a) }' >>$@

build/%.dat: cadran.sh build/cadran
	$< $(YEAR) $(LAT) $(LON)\
	 $(STRAIGHT_STYLUS_LENGTH) $(GNOMONIC_DECLINATION) $(STYLUS_ANGLE) $@

cadran.pdf: cadran.tex build/config.tex\
 build/hiv07.dat build/pri07.dat build/ete07.dat build/aut07.dat\
 build/hiv08.dat build/pri08.dat build/ete08.dat build/aut08.dat\
 build/hiv09.dat build/pri09.dat build/ete09.dat build/aut09.dat\
 build/hiv10.dat build/pri10.dat build/ete10.dat build/aut10.dat\
 build/hiv11.dat build/pri11.dat build/ete11.dat build/aut11.dat\
 build/hiv12.dat build/pri12.dat build/ete12.dat build/aut12.dat\
 build/hiv13.dat build/pri13.dat build/ete13.dat build/aut13.dat\
 build/hiv14.dat build/pri14.dat build/ete14.dat build/aut14.dat\
 build/hiv15.dat build/pri15.dat build/ete15.dat build/aut15.dat\
 build/hiv16.dat build/pri16.dat build/ete16.dat build/aut16.dat\
 build/hiv17.dat build/pri17.dat build/ete17.dat build/aut17.dat\
 build/hiv07_5.dat build/pri07_5.dat build/ete07_5.dat build/aut07_5.dat\
 build/hiv08_5.dat build/pri08_5.dat build/ete08_5.dat build/aut08_5.dat\
 build/hiv09_5.dat build/pri09_5.dat build/ete09_5.dat build/aut09_5.dat\
 build/hiv10_5.dat build/pri10_5.dat build/ete10_5.dat build/aut10_5.dat\
 build/hiv11_5.dat build/pri11_5.dat build/ete11_5.dat build/aut11_5.dat\
 build/hiv12_5.dat build/pri12_5.dat build/ete12_5.dat build/aut12_5.dat\
 build/hiv13_5.dat build/pri13_5.dat build/ete13_5.dat build/aut13_5.dat\
 build/hiv14_5.dat build/pri14_5.dat build/ete14_5.dat build/aut14_5.dat\
 build/hiv15_5.dat build/pri15_5.dat build/ete15_5.dat build/aut15_5.dat\
 build/hiv16_5.dat build/pri16_5.dat build/ete16_5.dat build/aut16_5.dat
	cd build && pdflatex --halt-on-error ../$<
	mv build/$@ .

.PHONY: gcode
gcode: cadran.nc
cadran.nc: gcode.py gcode7seg.py build/config.tex\
 build/hiv07.dat build/pri07.dat build/ete07.dat build/aut07.dat\
 build/hiv08.dat build/pri08.dat build/ete08.dat build/aut08.dat\
 build/hiv09.dat build/pri09.dat build/ete09.dat build/aut09.dat\
 build/hiv10.dat build/pri10.dat build/ete10.dat build/aut10.dat\
 build/hiv11.dat build/pri11.dat build/ete11.dat build/aut11.dat\
 build/hiv12.dat build/pri12.dat build/ete12.dat build/aut12.dat\
 build/hiv13.dat build/pri13.dat build/ete13.dat build/aut13.dat\
 build/hiv14.dat build/pri14.dat build/ete14.dat build/aut14.dat\
 build/hiv15.dat build/pri15.dat build/ete15.dat build/aut15.dat\
 build/hiv16.dat build/pri16.dat build/ete16.dat build/aut16.dat\
 build/hiv17.dat build/pri17.dat build/ete17.dat build/aut17.dat\
 build/hiv07_5.dat build/pri07_5.dat build/ete07_5.dat build/aut07_5.dat\
 build/hiv08_5.dat build/pri08_5.dat build/ete08_5.dat build/aut08_5.dat\
 build/hiv09_5.dat build/pri09_5.dat build/ete09_5.dat build/aut09_5.dat\
 build/hiv10_5.dat build/pri10_5.dat build/ete10_5.dat build/aut10_5.dat\
 build/hiv11_5.dat build/pri11_5.dat build/ete11_5.dat build/aut11_5.dat\
 build/hiv12_5.dat build/pri12_5.dat build/ete12_5.dat build/aut12_5.dat\
 build/hiv13_5.dat build/pri13_5.dat build/ete13_5.dat build/aut13_5.dat\
 build/hiv14_5.dat build/pri14_5.dat build/ete14_5.dat build/aut14_5.dat\
 build/hiv15_5.dat build/pri15_5.dat build/ete15_5.dat build/aut15_5.dat\
 build/hiv16_5.dat build/pri16_5.dat build/ete16_5.dat build/aut16_5.dat
	@$< >$@

portrait-%.pdf: %.pdf
	pdfjam -q --angle 90 -o $@ $<

.PHONY: dist-clean
dist-clean:
	@$(RM) *.pdf build/*.tex build/*.dat build/moon-*

PROJECT=cal
include $(PROROOT)/makefiles/tar.mk
